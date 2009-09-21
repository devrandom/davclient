# Implementation of the 'dav-put' command line utility.

require 'rubygems'
require 'davclient'
require 'optparse'

class PutCLI

  def self.put(args)

    options = read_options(args)
    url = args[0]
    if(options[:string])then

      # Put string
      if(!url.match(/^http.*\/\/([^\/]*)/) and !WebDAV.CWURL)
        raise "Error: No current working url set. Use '#{$0} cd url' to set url."
      end

      begin
        WebDAV.put_string(url,options[:string])
      rescue
        puts $0 + ": " + $!
      end
      puts "Published content to: " + url
    else

      # Put files(s)

      #  puts "DEBUG: size:" + args.size.to_s

      if(args.size == 1 )
        local_file = args[0]
        if(not(File.exists?(local_file)))
          raise "File not found: #{local_file}"
        end
        if(!WebDAV.CWURL)
          raise "Error: No current working url set. Use '#{$0} cd url' to set url."
        end

        WebDAV.put(WebDAV.CWURL, local_file)

      elsif(args.size == 2 and args[1].match(/^http.*\/\/([^\/]*)/) )
        local_file = args[0]
        url = args[1]

        if(not(File.exists?(local_file)))
          raise "File not found: #{local_file}"
        end

        if(WebDAV.isCollection?(url))
          url += File.basename(local_file)
        end

        WebDAV.put(url, local_file)

      else

        # Put more than one file

        if(args.last.match(/^http.*\/\/([^\/]*)/) )
           url = args.last
           if(!WebDAV.isCollection?(url))
             raise "Destination collection not found: " + url
           end
           args = args[0..(args.size-2)]
        else
          url = WebDAV.CWURL
        end

        count = 0
        args.each do | arg|
          # puts "arg:" + arg
          if(File.ftype(arg) == 'directory')
            raise "Upload directories not implemented"
          end
          if(File.exists?(arg))
            basename = File.basename(arg)
            WebDAV.put(url + basename, arg)
            count = count + 1
          else
            raise "Error: File not found " + arg
          end
        end
        puts "Published #{count} files to #{url}"
      end
    end

  end

  private

  def self.read_options(args)
    options = {}

    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: #{$0} put [options] [filelist][url]"

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        puts
        puts "Upload local file or files to server."
        puts
        puts "Examples:"
        puts
        puts "       #{$0} put local_file"
        puts "       #{$0} put local_filename https://dav.org/remote_filename"
        puts "       #{$0} put *.html https://dav.org/remote_collection/"
        puts "       #{$0} put --string \"Hello world\" hello_world.html"
        puts
        exit
      end

      options[:string] = false
      opts.on( '-s', '--string STRING', "Put contents of string" ) do |str |
        options[:string] = str
      end

    end

    begin
      optparse.parse! args
    rescue
      puts "Error: " + $!
      puts optparse
      exit
    end

    return options
  end

end

# Make this file an executable script
if $0 == __FILE__
  PutCLI.put(ARGV)
end
