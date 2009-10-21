# -*- coding: utf-8 -*-

require 'hpricot'
require 'pathname'
require 'davclient/hpricot_extensions'
require 'davclient/curl_commands'
require 'davclient/util'

# :stopdoc:

# Path to curl executable:
$curl = "curl"



# :startdoc:

# Main WebDAV client. Current working URL is stored in a tempfile named /tmp/cwurl.pid, where pid is the parent process.
# Username an password is stored in the ~/.netrc file. This means there is no need to set up any sessions or connections.
#
# If a change directory command is executed with a relative path, like for instance WebDAV.cd("../collection"), it will
# raise an exception if current working url has not been set. First a change directory command is executed it should
# use an absolute URL, like for instance WebDAV.cd("https://www.webdav.org/collection/").
#
# If using an URL with a server name not found in the ~/.netrc file, instructions for adding
# the necessary servername, username and password will be printed to stdout.
#
module WebDAV

  # :stopdoc:
  VERSION = '0.0.4'
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns current working url.
  def self.CWURL
    return $CWURL if($CWURL)
    cwurl = nil
    filename = DavClient.cwurl_filename
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
        raise "illegal url: " + url
      end
    end
    return url
  end

  # Boolean function that returns true if url is a collection
  #
  # Example:
  #
  #    WebDAV.isCollection("../test.html") => false
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
  # First time this method is called, an absolute URL
  # must be used. Raises exception if servername is not
  # found in ~/.netrc file.
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

  # Sets current working url.
  #
  # Current working url is stored in aa tempfile with parent process pid
  # as part of the filename.
  def self.CWURL=(url)
    $CWURL = url
    File.open(DavClient.cwurl_filename, 'w') {|f| f.write(url) }
    # puts "DEBUG: writing " + DavClient.cwurl_filename
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

    curl_command = url
    return DavClient.exec_curl(curl_command)
  end

  # Set WebDAV properties for url as xml.
  #
  # Example:
  #
  #   WebDAV.proppatch("https://dav.webdav.org/folder","<contentLastModified>2007-12-12 12:00:00 GMT</contentLastModified>
  def self.proppatch(url, property)
    url = absoluteUrl(url)
    curl_command = CURL_PROPPATCH + " \""+url+"\""
    curl_command = curl_command.gsub("<!--property-and-value-->",property)
    response = DavClient.exec_curl(curl_command)
    if(not(response =~ /200 OK/)) then
      puts "Error:\nRequest:\n" + curl_command + "\n\nResponse: " + response
      exit(0)
    end
  end

  # Get WebDAV properties
  #
  # Examples:
  #
  #   item = propfind(url)                - Returns an Hpricot::Elem object
  #
  #   xml = propfind(url, :xml => true)   - Returns xml for debugging.
  def self.propfind(*args)
    url = args[0]
    url = absoluteUrl(url)
    options = args[1]

    curl_command = CURL_PROPFIND + " \"" + url + "\""
    response = DavClient.exec_curl(curl_command)

    if(response == "")then
      return nil
    end

    if(not(response =~ /200 OK/)) then
      # puts "Error:\nRequest:\n" + curl_command + "\n\nResponse: " + response
      # exit(0)
      raise "Error:\nRequest:\n" + curl_command + "\n\nResponse: " + response
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
  #  result = find( url [:type => "collection"|"resource"] [:recursive => true])
  #
  #  result = find( url, :type => "collection" ,:recursive => true)
  #
  # You can also pass a block of code:
  #
  #  find( url, :type => "collection" ,:recursive => true) do |folder|
  #    puts folder.href
  #  end
  #
  # If no url is specified, current working url is used.
  #
  #       cd("https://webdav.org")
  #       find() do |item|
  #         print item.title
  #       end
  def self.find(*args, &block)

    if(args.size == 0)
      href = self.CWURL
    elsif(args.size == 1)
      if(args[0].class == String)
        href = args[0]
      else
        options = args[0]
      end
    elsif(args.size == 2)
      href = args[0]
      options = args[1]
    else
      raise "Illegal number of arguments."
    end

    if(href == nil )
      if(WebDAV.CWURL == nil)
        raise "no current working url set"
      else
        href = WebDAV.CWURL
      end
    end

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
    begin
      dav_xml_output = propfind(href, :xml => true)
    rescue Exception => exception
      $stderr.puts "Warning: " + href + " : " + exception
      # raise "er
      return nil
    end
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
          if((type == "collection" or type == "folder" or type == "directory") and item.isCollection? )then
            items_filtered.push(item)
            if(block) then
              yield item
            end
          end

          # TODO BUG: Item is not yielded if :type => "resource" is given...
          # puts "DEBUG: " + type + "  " + item.isCollection?.to_s
          if( (type == "file" or type == "resource") and item.isCollection? == false )then
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
    response = DavClient.exec_curl(curl_command)

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
    response = DavClient.exec_curl(curl_command)

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
    response = DavClient.exec_curl(curl_command)

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
    response = DavClient.exec_curl(curl_command)

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

    filename = DavClient.string2tempfile(str)
    put(url,filename)
  end


  # Upload local file to webserver
  #
  # Example:
  #
  #  WebDAV.put("https://example.org/myfile.html", "myfile.html")
  def self.put(url, file_name)
    url = absoluteUrl(url)

    curl_command = CURL_UPLOAD + " " + file_name + " " + url
    response = DavClient.exec_curl(curl_command)
    if(response != "" and not(response =~ /200 OK/)) then
      raise "Error:\n WebDAV.put: WebDAV Request:\n" + curl_command + "\n\nResponse: " + response
    end
  end

  # Returns a string with the webservers WebDAV options (PUT, PROPFIND, etc.)
  def self.options(url)
    if(not(url))
      url = self.CWURL
    end
    return DavClient.exec_curl(CURL_OPTIONS + url )
  end

end
