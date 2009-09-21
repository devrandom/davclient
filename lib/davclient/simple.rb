# For simple WebDAV scritps where namespacing is not necessary
# require 'davclient/simple' to get a simple api

require 'davclient'
require 'davclient/dav-ls'

def cd(args)
  WebDAV.cd(args)
end

def pwd
  WebDAV.CWURL
end

def find(*args, &block)
  WebDAV.find(*args, &block)
end

def ls(*args)
  if(args == [])
    LsCLI.ls([WebDAV.CWURL])
  else
    LsCLI.ls(*args)
  end
end

def get(args)
  WebDAV.get(args)
end

puts "Demo"
cd "https://vortex-dav.uio.no/brukere/thomasfl/"
