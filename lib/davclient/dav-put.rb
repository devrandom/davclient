# WebDav put command line utility
# Synopsis:
#       dav put [options][url]
#
# or standalone:
#
#     ruby dav-ls  [options][url]

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
      puts "PUT file not implemented"
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
