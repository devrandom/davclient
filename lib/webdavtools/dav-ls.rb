# WebDav ls command line utility
# Synopsis:
#       wdav ls [options][url]
#
require 'rubygems'
require 'webdavtools'
require 'optparse'

module WDav

  def self.ls(args)
    options = read_options(args)
    url = args[0]
    if(not url)then
      url = WebDAV.CWURL
      if(not url)then
        puts "wdav ls: no current working url"
        puts "Usage: Use 'wdav open url' or 'wdav cd [url|dir] to set current working url"
        exit
      end
    else
      WebDAV.CWURL = url
    end

    WebDAV.find(url, :recursive => false ) do |item|
      if(options[:showUrl])then
        puts item.href
      elsif(options[:longFormat])

      else
        print item.basename
        print "/" if item.isCollection?
        puts
      end
    end
  end

  private

  def self.read_options(args)
    options = {}

    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: #{$0} ls [options] url"

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end

      options[:longFormat] = false
      opts.on( '-l', "List in long format" ) do
        options[:longFormat] = true
      end

      options[:showUrl] = false
      opts.on('-a', "Include full url in names.") do
        options[:showUrl] = true
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
  WDav.ls(ARGV)
end
