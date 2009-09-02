# Rakefile for WebDAVTools   -*- ruby -*-
# Usage:
#
#  gem build Rakefile
#  sudo gem install webdavtools-x.x.x.gem

spec = Gem::Specification.new do |s|
  s.name = "webdavtools"
  s.version = "0.0.6"
  s.author = "Thomas Flemming"
  s.email = "thomas.flemming@gmail.com"
  s.homepage = "http://folk.uio.no/thomasfl"
  s.platform = Gem::Platform::RUBY
  s.summary = "Command line WebDAV client and Ruby library."
  s.description = "WebDAV client written in Ruby for managing " +
                  "content on webservers that support the WebDAV extensions."
  s.requirements << "cURL command line tool available from http://curl.haxx.se/"
  s.requirements << "Servername, username and password must be supplied in ~/.netrc file."
  s.files = ["lib/webdavtools.rb","lib/webdavtools/hpricot_extensions.rb",
             "lib/webdavtools/curl_commands.rb", "bin/dav",
              "lib/webdavtools/dav-ls.rb","lib/webdavtools/dav-pwd.rb",
              "lib/webdavtools/dav-cd.rb", "lib/webdavtools/dav-propfind.rb"]
  s.executables = ["dav"]
  s.require_path = "lib"
  s.rubyforge_project = "webdavtools"
  #  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("zentest", ">= 3.5") # For tests
end

