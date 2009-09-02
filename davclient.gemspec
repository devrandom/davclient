# Rakefile for File::Tail      -*- ruby -*-
require 'rubygems'
require 'rbconfig'

spec = Gem::Specification.new do |s|
  s.name = "WebDAVTools"
  s.version = "0.0.1"
  s.author = "Thomas Flemming"
  s.email = "thomas.flemming@gmail.com"
  s.homepage = "http://folk.uio.no/thomasfl"
  s.platform = Gem::Platform::RUBY
  s.summary = "Command line WebDAV client and library."
  s.files = FileList["{bin,lib}/**/*"].to_a
  s.require_path = "lib"
  s.autorequire = "webdavtools.rb"
  #  s.test_files = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.add_dependency("hpricot", ">= 0.6")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
