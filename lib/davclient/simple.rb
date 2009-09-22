# A minimalistic API for interacting with WebDAV servers.
#
# If commands needs to Simple WebDAV API for use in scripts where namespacing is not necessary.

# :stopdoc:

require 'davclient'
require 'davclient/dav-ls'

# :startdoc:

# Change working directory.
#
# Examples:
#
#    require 'davclient/simple'
#
#    cd("https://example.webdav.org/collection/")
#    content = get("index.html")
#    print content
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

