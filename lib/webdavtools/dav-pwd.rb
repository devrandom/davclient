# Handle command 'wdav pwd'
require 'rubygems'
require 'webdavtools'

url = WebDAV.CWURL
if(url)then
  puts url
else
  puts "wdav pwd: no current working url set. Use 'wdav cd url' to set url."
end
