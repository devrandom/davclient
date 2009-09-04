# WebDav ls command line utility
# Synopsis:
#       dav ls [options][url]
#
# or standalone:
#
#     ruby dav-ls  [options][url]

require 'rubygems'
require 'davclient'
require 'optparse'

class LsCLI

  def self.ls(args)
    options = read_options(args)
    url = args[0]
    tmp_cwurl = WebDAV.CWURL
    if(not url)then
      url = WebDAV.CWURL
      if(not url)then
        puts "#{$0} ls: no current working url"
        puts "Usage: Use '#{$0} cd [url|dir] to set current working url"
        exit
      end
    else
      WebDAV.cd(url)
    end

    url = WebDAV.CWURL
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

    # Restore CWURL
    WebDAV.cd(tmp_cwurl)
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
  LsCLI.ls(ARGV)
end
