# -*- coding: utf-8 -*-

require 'hpricot'
require 'tempfile'
require 'open3'
require 'davclient/hpricot_extensions'

# :stopdoc:

# Path to curl executable:
$curl = "curl"

require 'davclient/curl_commands'

# :startdoc:

# WebDAV client
module WebDAV

  # :stopdoc:
  VERSION = '0.0.5'
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

  # Sets current working url
  def self.CWURL=(url)
    $CWURL = url # Used by tests
    File.open(cwurl_filename, 'w') {|f| f.write(url) }
  end

  # Get content as string
  # Example:
  #    html = WebDAV.get(url)
  def self.get(href)
    curl_command = "#{$curl} --netrc " + href
    return exec_curl(curl_command)
  end

  # Set WebDAV properties for url as xml.
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
    href = args[0]
    options = args[1]

    curl_command = CURL_PROPFIND + " \"" + href + "\""
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
      if(item.href == href) then
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
  def self.mkcol(href,props)
    curl_command = CURL_MKCOL + " " + href
    response = exec_curl(curl_command)
    if(props)then
      proppatch(href,props)
    end
    if(response =~ />Created</)then
      return true
    end
    return response
  end

  # Delete resource
  def self.delete(href)
    curl_command = CURL_DELETE + href
    response = exec_curl(curl_command)

    if(response  == "")then
      return false
    end
    if(not(response =~ /200 OK/)) then
      puts "Error:\nRequest:\n" + curl_delete_command + "\n\nResponse: " + response
      return false
    end
    return true
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
  def self.put_string(url, html)
    if(url =~ /\/$/)then
      raise "Error: WebDAV.put_html: url can not be a collection (folder)."
    end

    tmp_dir = "/tmp/" + rand.to_s[2..10] + "/"
    FileUtils.mkdir_p tmp_dir
    tmp_file = tmp_dir + "webdav.tmp"
    File.open(tmp_file, 'w') {|f| f.write(html) }

    curl_command = "#{$curl} --netrc --silent --upload-file #{tmp_file} #{url}"
    response = exec_curl(curl_command)
    if(response != "" and not(response =~ /200 OK/)) then
      raise "Error:\n WebDAV.put: WebDAV Request:\n" + curl_command + "\n\nResponse: " + response
    end
  end

  # :stopdoc:

  # TODO put file utility
  # TESTME
  def put_file(filename, href)
    # TODO Detect if href is a collection or not??
    curl_command = "#{$curl} --netrc --request PUT #{filename} #{href}"
    return exec_curl(curl_command)
    # return execute_curl_cmd(curl_put_cmd)
  end
  # :startdoc:

  private

  # Returns filename /tmp/cwurl.#pid that holds the current working directory
  # for the shell's pid
  def self.cwurl_filename
    tmp_file = Tempfile.new("dummy").path
    basename = File.basename(tmp_file)
    tmp_folder = tmp_file.gsub(basename, "")
    return tmp_folder +  "cwurl." + Process.ppid.to_s
  end

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
