require 'tempfile'
require 'davclient/termutil'
require 'open3'

# DavClient Utilitis

module DavClient

  # Loads contents of property file into an array
  def self.load_davclientrc_file
    properties_filename = ENV['HOME'] + "/.davclientrc"
    return nil if not(File.exists?( properties_filename ))

    properties = []
    index = 0
    File.open(properties_filename, 'r') do |properties_file|
      properties_file.read.each_line do |line|
        line.strip!
        line = line.sub(/#.*/,"")
        if (line[0] != ?# and line[0] != ?= )
          i = line.index('=')
          if (i)
            # properties[line[0..i - 1].strip] = line[i + 1..-1].strip
            key = line[0..i - 1].strip
            if(key != "")
              properties[index] = [ key, line[i + 1..-1].strip ]
              index += 1
            end
          else
            key = line
            if(key != "" and not(key =~ /^\[/) )
              properties[index] = [key, '']
              index += 1
            end
          end

        end
      end
    end
    return properties
  end


  # Returns options for an url read from .davclientrc file
  def self.site_options(url, settings)
    settings.each_index do | index|
      key,value = settings[index]
      # puts key + "--->" + value + "  " + url
      if(url.match(key)  and key != "")then
        return value
      end
    end
    return ""
  end



  # Returns filename /tmp/cwurl.#pid that holds the current working directory
  # for the shell's pid
  def self.cwurl_filename
    return DavClient.tmp_folder +  "cwurl." + Process.ppid.to_s
  end


  # Returns name of temp folder we're using
  def self.tmp_folder
    tmp_file = Tempfile.new("dummy").path
    basename = File.basename(tmp_file)
    return  tmp_file.gsub(basename, "")
  end

  # Write string to tempfile and returns filename
  def self.string2tempfile(str)
    tmp_dir = DavClient.tmp_folder + rand.to_s[2..10] + "/"
    FileUtils.mkdir_p tmp_dir
    tmp_file = tmp_dir + "webdav.tmp"
    File.open(tmp_file, 'w') {|f| f.write(str) }
    return tmp_file
  end


  # Display instructions for adding credentials to .netrc file
  def self.display_unauthorized_message(href)
    puts "Error: 401 Unauthorized: " + href
    href.match(/^http.*\/\/([^\/]*)/)
#    puts "\nTry adding the following to your ~/.netrc file:"
#    puts ""
#    puts "machine #{$1}"
#    puts "  login    " + ENV['USER']
#    puts "  password ********"
#    puts ""
  end

  # Prompts user for username and password
  # Prints hostname to console if set.
  def self.prompt_for_username_and_password(host)
    if(host)
      print("Enter username for host '#{host}': ")
    else
      print("Username: ")
    end
    $stdout.flush
    $username = STDIN.gets
    $username.strip!
    $password = TermUtil.getc(message="Password: ", mask='*')
    $password.strip!
  end


  # Spawns a new process. Gives curl password if password
  # is not nil.
  def self.spawn_curl(command, password)
    PTY.spawn(command) do |reader, writer, pid|
      if(password)
        reader.expect(/^Enter.*:/)
        writer.puts(password)
      end
      answer = reader.readlines.join("")
      reader.close
      return answer
    end
  end

  def self.exctract_host(url)
    result = url.match(/http.*\/\/([^\/\?]*)/)
    if(result)
      return result[1]
    end
  end


  # Run 'curl' as a subprocess
  def self.exec_curl(curl_command)
    response = ""

    puts curl_command if($DEBUG)

    Open3.popen3(curl_command) do |stdin, stdout, stderr|

      response = stdout.readlines.join("")

      if(response == "")
        stderr = stderr.readlines.join("").sub(/^\W/,"")
        if(stderr =~ /command/)
          raise "Error: " + stderr
          # puts "Error: " + stderr
          # exit
        end
        if(stderr =~ /^curl:/)
          raise "Error: " + stderr
          # puts "Error: " + stderr
          # puts
          # puts curl_command
          # puts
          # exit
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

  # Run 'curl' as a subprocess with pty
  def self.exec_curl2(curl_command)
    response = ""
    puts curl_command if($DEBUG)

    url = curl_command.match("http[^ ]*$").to_s
    if(url == nil or url == "")then
      puts "Curl command does not contain url."
      raise RuntimeError
    end
    url = url.sub(/\"$/,"")
    host = exctract_host(url)

    settings = load_davclientrc_file
    options = site_options(url, settings)

    # puts;puts "url:" + url + " => '" + options + "'";

    if(options =~ /password-prompt/)  # no-password-prompt
      options = options.sub(/password-prompt/, "")

      if($username)
      # Is username stored in $username variable ???
      else
        print("Username: ")
        $stdout.flush
        $username = STDIN.gets
        $username.strip!
        require 'davclient/termutil'
        $password = TermUtil.getc(message="Password: ", mask='*')
        # $password.strip!
        puts "pass::" + $password
      end

      options += " --user " + $username + " "

    end

    curl_command = "#{$curl} " + options  + " " + curl_command

    puts
    puts curl_command

    Open3.popen3(curl_command) do |stdin, stdout, stderr|
      stdin.puts $password # + "\n"
      response = stdout.readlines.join("")
      if(response == "")
        stderr = stderr.readlines.join("").sub(/^\W/,"")
        if(stderr  =~ /command/)
          # puts "Error: " + stderr
          raise "Error: " + stderr
          # exit
        end
        if(stderr  =~ /^curl:/)
          raise "Error: " + stderr
          # puts "Error: " + stderr
          # puts
          # puts curl_command
          # puts
          # exit
        end
      end
    end
    if(response =~ /401 Unauthorized/)then
      href = curl_command #.match( /"(http[^\"]*)"$/ )[0].gsub(/"/,"")
      # DavClient.display_unauthorized_message(href)
      raise "Could not execute :" + response
    end
    return response
  end

end
