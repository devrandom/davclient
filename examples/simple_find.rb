require 'rubygems'
require 'davclient/simple'

# Simply print the url of all files and collections on server

cd "https://vortex-dav.uio.no/brukere/thomasfl/"

find do |item|
  puts item.href
end
