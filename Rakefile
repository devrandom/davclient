# Rakefile for DavClient   -*- ruby -*-
# Usage:
#
#  gem build Rakefile
#  sudo gem install davclient-x.x.x.gem

spec = Gem::Specification.new do |s|
  s.name = "davclient"
  s.version = "0.0.1"
  s.author = "Thomas Flemming"
  s.email = "thomasfl@usit.uio.no"
  s.homepage = "http://folk.uio.no/thomasfl"
  s.platform = Gem::Platform::RUBY
  s.summary = "Command line WebDAV client and Ruby library."
  s.description = "WebDAV command line client written in Ruby for managing " +
                  "content on webservers that support the WebDAV extensions."
  s.requirements << "cURL command line tool available from http://curl.haxx.se/"
  s.requirements << "Servername, username and password must be supplied in ~/.netrc file."
  s.files = ["lib/davclient.rb","lib/davclient/hpricot_extensions.rb",
             "lib/davclient/curl_commands.rb", "bin/dav",
              "lib/davclient/dav-ls.rb","lib/davclient/dav-pwd.rb",
              "lib/davclient/dav-cd.rb", "lib/davclient/dav-propfind.rb"]
  s.executables = ["dav"]
  s.require_path = "lib"
  s.rubyforge_project = "davclient"
  #  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("zentest", ">= 3.5") # For tests
end

