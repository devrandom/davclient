# Implementation of the 'dav-put' command line utility.

require 'rubygems'
require 'davclient'
require 'optparse'

class PutCLI

  def self.put(args)
    options = read_options(args)
    url = args[0]
    if(options[:string])then
      begin
        WebDAV.put_string(url,options[:string])
      rescue
        puts $0 + ": " + $!
      end
      puts "Published content to " + url
    else

      #
      # Put file
      #

      puts "DEBUG: size:" + args.size.to_s

      if(args.size == 1 )
        local_file = args[0]
        if(not(File.exists?(local_file)))
          puts "File: #{local_file} doesn't exist."
          # raise ...
          exit
        end
        if(!WebDAV.CWURL)
          puts "Error: No current working url set. Use '#{$0} cd url' to set url."
          # raise ..
          exit
        end

        WebDAV.put(WebDAV.CWURL, local_file)

      elsif(args.size == 2 and args[1].match(/^http.*\/\/([^\/]*)/) )
        local_file = args[0]

        # TODO: Use Pathname ?
        if(not(local_file =~ /^\//))
          puts "DEBUG: use pathname: " + local_file
          puts "not implemented"
          exit
        end

        if(not(File.exists?(local_file)))
          puts "File: #{local_file} doesn't exist."
          # raise ...
          exit
        end

        url = args[1]
        if(WebDAV.isCollection?(url))
          # puts "DEBUG; isCollection"
          url += File.basename(local_file)
        end

        # puts "ok: " + url + " " + local_file
        WebDAV.put(url, local_file)
      else

        args.each do | arg|
          puts "arg:" + arg
        end
        # TODO
        #  - 2 args: 1. local-file 2.url-med-filnavn
        #  - Siste arg =~ http?://
        puts "PUT file not implemented"

      end
    end

  end

  private

  def self.usage()
    puts "Usage: #{$0} put --string \"<html>..</html>\" url"
  end

  def self.read_options(args)
    options = {}

    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: #{$0} put [options] url"

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end

      options[:string] = false
      opts.on( '-s', '--string', "Put contents of string" ) do |str |
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
