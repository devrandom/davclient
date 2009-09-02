# WebDav cd command line utility
# Synopsis:
#       wdav cd [url|foldername|..]
#

require 'rubygems'
require 'webdavtools'

module WDav

  def self.cd(args)
    url = args[0]
    if(url =~ /^http/)then
      set_cwurl(url)
    else
      if(url)then
         if(url == "..")then
          # TODO: Standard-lib 'File' class can handle
          # proabably handle cd ../.. etc. better
          url = WebDAV.CWURL.sub(/[^\/]*\/$/, "")
           set_cwurl(url)
        else
          url = WebDAV.CWURL + url
          set_cwurl(url)
        end
      else
        puts "usage: "
      end
    end
  end

  private

  def self.set_cwurl(url)
    if(not(url =~ /\/$/))then
      url += "/"
    end
    resource = WebDAV.propfind(url)
    if(resource and resource.isCollection?)then
      WebDAV.CWURL = url
      puts "Set WebDAV URL: " + url
    else
      puts "Error: URL is not a WebDAV collection."
    end
  end

end

# Make this script file executable
if $0 == __FILE__
  WDav.cd(ARGV)
end
