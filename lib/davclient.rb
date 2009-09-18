# -*- coding: utf-8 -*-

require 'hpricot'
require 'tempfile'
require 'open3'
require 'pathname'
require 'davclient/hpricot_extensions'

# :stopdoc:

# Path to curl executable:
$curl = "curl"

require 'davclient/curl_commands'

# :startdoc:

# WebDAV client
module WebDAV

  # :stopdoc:
  VERSION = '0.0.4'
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns current working url. Used by command line utilites
  def self.CWURL
    return $CWURL if($CWURL) # Used by tests
    cwurl = nil
    filename = cwurl_filename
    if(File.exists?(filename))
      File.open(filename, 'r') {|f| cwurl = f.read() }
    end
    return cwurl
  end

  # Make relative url absolute. Returns error if no current working
  # url has been set.
  #
  # Example:
  #
  #   WebDAV.cd("https://example.org/subfolder")
  #   print WebDAV.absoluteUrl("..")  => "https://example.org/"
  def self.absoluteUrl(url)
    if(not(url =~ /^http.?:\/\//))then
      cwurl = Pathname.new(self.CWURL)
      cwurl = cwurl + url
      url = cwurl.to_s
      # url = url + "/" if(not(url =~ /\/$/))

      if(not(url =~ /^http.?:\/\//))then
        warn "#{$0}: Error: illegal url: " + url
        exit
      end
    end
    return url
  end

  # Returns true if url is a collection
  def self.isCollection?(url)
    url = absoluteUrl(url)
    url = url + "/" if(not(url =~ /\/$/))
    resource = WebDAV.propfind(url)
    if(resource == nil)
      return false
    else
      return resource.isCollection?
    end
  end

  # Change current working url. Takes relative pathnames.
  #
  # Examples:
  #
  #   WebDAV.cd("http://www.example.org")
  #
  #   WebDAV.cd("../folder")
  def self.cd(url)
    url = absoluteUrl(url)
    url = url + "/" if(not(url =~ /\/$/))
    resource = WebDAV.propfind(url)
    if(resource and resource.isCollection?)then
      WebDAV.CWURL = url
    else
      raise Exception, "#{$0} cd: #{url}: No such collection on remote server."
    end
  end

  # Sets current working url by storing url in a tempfile with parent process pid
  # as part of the filename.
  def self.CWURL=(url)
    $CWURL = url # Used by tests
    File.open(cwurl_filename, 'w') {|f| f.write(url) }
  end


  # Get content of resource as string
  #
  # Example:
  #
  #    html = WebDAV.get(url)
  #
  #    html = WebDAV.get("file_in_current_working_folder.html")
  def self.get(url)
    url = absoluteUrl(url)

    curl_command = "#{$curl} --netrc " + url
    return exec_curl(curl_command)
  end

  # Set WebDAV properties for url as xml.
  #
  # Example:
  #
  #   WebDAV.proppatch("https://dav.webdav.org/folder","<contentLastModified>2007-12-12 12:00:00 GMT</contentLastModified>
  def self.proppatch(href, property)
    curl_command = CURL_PROPPATCH + " \""+href+"\""
    curl_command = curl_command.gsub("<!--property-and-value-->",property)
    response = exec_curl(curl_command)
    if(not(response =~ /200 OK/)) then
      puts "Error:\nRequest:\n" + curl_command + "\n\nResponse: " + response
      exit(0)
    end
  end

  # Get WebDAV properties
  #
  # Examples:
  #   item = propfind(url)                - Returns a Hpricot::Elem object
  #
  #   xml = propfind(url, :xml => true)   - Returns xml for debugging.
  def self.propfind(*args)
    url = args[0]
    url = absoluteUrl(url)
    options = args[1]

    curl_command = CURL_PROPFIND + " \"" + url + "\""
    response = exec_curl(curl_command)

    if(response == "")then
      return nil
    end

    if(not(response =~ /200 OK/)) then
      puts "Error:\nRequest:\n" + curl_command + "\n\nResponse: " + response
      exit(0)
    end

    if(options and options[:xml])then
      return response
    end
    doc = Hpricot( response )
    items_filtered = Array.new()
    items = doc.search("//d:response").reverse
    items.each do |item|

      # Only return root item if folder
      if(item.href == url or item.href == url + "/" ) then
        return item
      end
    end
    return nil
  end

  # Find files and folders.
  #
  # Examples:
  #
  #  result = find( url )
  #
  #  result = find( url, :type => "collection" ,:recursive => true)
  #
  # You can also pass a block of code:
  #
  #  find( url, :type => "collection" ,:recursive => true) do |folder|
  #    puts folder.href
  #  end
  #
  def self.find(*args, &block)
    href = args[0]
    options = args[1]
    type = nil
    recursive = false
    if(options)then

      if(options[:type])then
        type = options[:type]
      end
      if(options[:recursive])then
        recursive = options[:recursive]
      end
    end
    dav_xml_output = propfind(href, :xml => true)
    if(not(dav_xml_output))then
      return nil
    end

    doc = Hpricot( dav_xml_output )
    items_filtered = Array.new()
    items = doc.search("//d:response").reverse

    # filter items
    items.each do |item|

      # Ignore info about root item (file or folder)
      if(item.href != href) then

        if(type == nil)then
          # No filters
          items_filtered.push(item)
          if(block) then
            yield item
          end

        else
          # Filter result set
          if((type == "collection" or type == "folder") and item.collection )then
            items_filtered.push(item)
            if(block) then
              yield item
            end
          end
          if(type == "file" and item.collection == false )then
            items_filtered.push(item)
            if(block) then
              yield item
            end
          end
        end

      end
    end

    if(recursive)then
      items_filtered.each do |item|
        if(item.collection && item.href != args[0])then
          result = find(item.href, args[1], &block)
          if(result != nil)
            items_filtered.concat( result)
          end
        end
      end
    end

    return items_filtered
  end

  # Make collection
  # Accepts relative url's
  def self.mkcol(*args) # url, props)
    url = args[0]
    props = args[3]
    url = absoluteUrl(url)
    curl_command = CURL_MKCOL + " " + url
    response = exec_curl(curl_command)

    if(props)then
      proppatch(url,props)
    end
    if(response =~ />Created</)then
      return true
    end
    return response
  end

  # Returns true if resource exists
  def self.exists?(url)
    url = absoluteUrl(url)
    props = WebDAV.propfind(url)
    if(props.to_s.size == 0)then
      return false
    else
      return true
    end
  end

  # Copy resources
  #
  # Examples:
  #
  #     WebDAV.cp("src.html","https://example.org/destination/destination.html"
  def self.cp(src,dest)
    srcUrl = absoluteUrl(src)
    destUrl = absoluteUrl(dest)

    # puts "DEBUG: " + srcUrl + " => " + destUrl
    curl_command = CURL_COPY.sub("<!--destination-->", destUrl) + " " + srcUrl
    response = exec_curl(curl_command)

    if(response  == "")then
      return destUrl
    end
    return false
  end


  # Move resources
  #
  # Examples:
  #
  #     WebDAV.mv("src.html","https://example.org/destination/destination.html"
  def self.mv(src,dest)
    srcUrl = absoluteUrl(src)
    destUrl = absoluteUrl(dest)

    # puts "DEBUG: " + srcUrl + " => " + destUrl
    curl_command = CURL_MOVE.sub("<!--destination-->", destUrl) + " " + srcUrl
    response = exec_curl(curl_command)

    if(response  == "")then
      return destUrl
    end
    return false
  end


  # Delete resource
  #
  # Examples:
  #
  #   WebDAV.cd("https://example.org/folder")
  #   WebDAV.mkcol("subfolder")
  #   WebDAV.delete("subfolder")
  def self.delete(url)

    url = absoluteUrl(url)

    curl_command = CURL_DELETE + url
    response = exec_curl(curl_command)

    if(response  == "")then
      return url
    end
    if(not(response =~ /200 OK/)) then
      puts "Error:\nRequest:\n" + curl_command + "\n\nResponse: " + response
      return false
    end
    return url
  end


  # Low level WebDAV publish
  #
  # Example:
  #
  #   WebDAV.publish("https://dav.example.org/index.html","<h1>Hello</h1>",nil)
  def self.publish(url, string, props)
    self.put_string(url, string)
    if(props)then
      self.proppatch(url,props)
    end
  end



  # Puts content of string to file on server with url
  #
  # Example:
  #
  #   WebDAV.put("https://dav.webdav.org/file.html", "<html><h1>Test</h1></html>"
  def self.put_string(url,str)
    url = absoluteUrl(url)

    if(url =~ /\/$/)then
      raise "Error: WebDAV.put_html: url can not be a collection (folder)."
    end

    filename = string2tempfile(str)
    put(url,filename)
  end


  # Upload local file
  def self.put(url, file_name)
    url = absoluteUrl(url)

    curl_command = "#{$curl} --netrc --silent --upload-file #{file_name} #{url}"
    response = exec_curl(curl_command)
    if(response != "" and not(response =~ /200 OK/)) then
      raise "Error:\n WebDAV.put: WebDAV Request:\n" + curl_command + "\n\nResponse: " + response
    end
  end

  # Returns a string with the webservers WebDAV options (PUT, PROPFIND, etc.)
  def self.options(url)
    if(not(url))
      url = self.CWURL
    end
    return self.exec_curl(CURL_OPTIONS + url )
  end

  # Returns name of temp folder we're using
  # TODO: Move this to utility library
  def self.tmp_folder
    tmp_file = Tempfile.new("dummy").path
    basename = File.basename(tmp_file)
    return  tmp_file.gsub(basename, "")
  end


  # TODO: Move this to utility library
  # Write string to tempfile and returns filename
  def self.string2tempfile(str)
    tmp_dir = tmp_folder + rand.to_s[2..10] + "/"
    FileUtils.mkdir_p tmp_dir
    tmp_file = tmp_dir + "webdav.tmp"
    File.open(tmp_file, 'w') {|f| f.write(str) }
    return tmp_file
  end



  # Returns filename /tmp/cwurl.#pid that holds the current working directory
  # for the shell's pid
  def self.cwurl_filename
    return tmp_folder +  "cwurl." + Process.ppid.to_s
  end

  private

  # Display instructions for adding credentials to .netrc file
  def self.display_unauthorized_message(href)
    puts "Error: 401 Unauthorized: " + href
    href.match(/^http.*\/\/([^\/]*)/)
    puts "\nTry adding the following to your ~/.netrc file:"
    puts ""
    puts "machine #{$1}"
    puts "  login    " + ENV['USER']
    puts "  password ********"
    puts ""
  end


  # Run 'curl' as a subprocess
  def self.exec_curl(curl_command)
    response = ""

    puts curl_command if($DEBUG)

    Open3.popen3(curl_command) do |stdin, stdout, stderr|

      response = stdout.readlines.join("")

      if(response == "")
        stderr = stderr.readlines.join("").sub(/^\W/,"")
        if(stderr  =~ /command/)
          puts "Error: " + stderr
          exit
        end
        if(stderr  =~ /^curl:/)
          puts "Error: " + stderr
          puts
          puts curl_command
          puts
          exit
        end
      end
    end
    if(response =~ /401 Unauthorized/)then
      href = curl_command.match( /"(http[^\"]*)"$/ )[0].gsub(/"/,"")
      self.display_unauthorized_message(href)
      exit
    end
    return response
  end


end
