# Rakefile for DavClient   -*- ruby -*-
# Usage:
#
#     rake package      Create gem
#     rake rdoc         Create doc
#     rake upload-docs  Upload docs to rubyforge
#
#     rake install      Create and install gem
#     rake manifest     Create manifest
#     rake release      Release to rubyforge

require 'rake/rdoctask'
require 'rake/gempackagetask'

GEM_VERSION = "0.0.6"

spec = Gem::Specification.new do |s|
  s.name = "davclient"
  s.version = GEM_VERSION
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
             "lib/davclient/curl_commands.rb", "bin/dav", "lib/davclient/davcli.rb",
             "lib/davclient/dav-put.rb", "lib/davclient/dav-ls.rb",
             "lib/davclient/dav-propfind.rb"]
  s.executables = ["dav"]
  s.require_path = "lib"
  s.rubyforge_project = "davclient"
  #  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  s.add_dependency("hpricot", ">= 0.6")
  s.add_dependency("ZenTest", ">= 3.5") # For tests
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end


html_dir = 'doc/html'
library = 'Ruby DavClient'
Rake::RDocTask.new('rdoc') do |t|
  t.rdoc_files.include('README.rdoc',
                       'lib/davclient.rb',
                       'lib/davclient/hpricot_extensions.rb',
                       'lib/davclient/simple.rb')
  t.main = 'README.rdoc'
  t.title = "#{library} API documentation"
  t.rdoc_dir = html_dir
end

rubyforge_user = 'thomasfl'
rubyforge_project = 'davclient'
rubyforge_path = "/var/www/gforge-projects/#{rubyforge_project}/"
desc 'Upload documentation to RubyForge.'
task 'upload-docs' => ['rdoc'] do
  sh "scp -r #{html_dir}/* " +
    "#{rubyforge_user}@rubyforge.org:#{rubyforge_path}"
end


website_dir = 'site'
desc 'Update project website to RubyForge.'
task 'upload-site' do
  sh "scp -r #{website_dir}/* " +
    "#{rubyforge_user}@rubyforge.org:/var/www/gforge-projects/project/"
end

desc 'Update API docs and project website to RubyForge.'
task 'publish' => ['upload-docs', 'upload-site']



require 'echoe'

Echoe.new('davclient',  GEM_VERSION) do |p|
  p.description    = "Command line WebDAV client and Ruby library."
  p.url            = "http://davclient.rubyforge.org/davclient"
  p.author         = "Thomas Flemming"
  p.email          = "thomasfl@usit.uio.no"
  p.ignore_pattern = ["svn_user.yml", "svn_project.rake"]
  p.project        = "davclient"
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }
