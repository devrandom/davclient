# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{davclient}
  s.version = "0.0.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Flemming"]
  s.date = %q{2009-10-21}
  s.default_executable = %q{dav}
  s.description = %q{Command line WebDAV client and Ruby library.}
  s.email = %q{thomasfl@usit.uio.no}
  s.executables = ["dav"]
  s.extra_rdoc_files = ["LICENSE", "README.rdoc", "bin/dav", "lib/davclient.rb", "lib/davclient/curl_commands.rb", "lib/davclient/dav-ls.rb", "lib/davclient/dav-propfind.rb", "lib/davclient/dav-put.rb", "lib/davclient/davcli.rb", "lib/davclient/hpricot_extensions.rb", "lib/davclient/simple.rb", "lib/davclient/termutil.rb", "lib/davclient/util.rb"]
  s.files = ["LICENSE", "Manifest", "README.rdoc", "Rakefile", "bin/dav", "examples/meta_tags_in_use.rb", "examples/remove_ds_store.rb", "examples/scrape_site.rb", "examples/simple_find.rb", "lib/davclient.rb", "lib/davclient/curl_commands.rb", "lib/davclient/dav-ls.rb", "lib/davclient/dav-propfind.rb", "lib/davclient/dav-put.rb", "lib/davclient/davcli.rb", "lib/davclient/hpricot_extensions.rb", "lib/davclient/simple.rb", "lib/davclient/termutil.rb", "lib/davclient/util.rb", "tests/dav.rb", "tests/tc_dav-cat.rb", "tests/tc_dav-cd.rb", "tests/tc_dav-cp.rb", "tests/tc_dav-delete.rb", "tests/tc_dav-get.rb", "tests/tc_dav-ls.rb", "tests/tc_dav-mkcol.rb", "tests/tc_dav-mv.rb", "tests/tc_dav-propfind.rb", "tests/tc_dav-put.rb", "tests/tc_property_file.rb", "tests/tc_util.rb", "tests/tc_webdav_basic.rb", "tests/tc_webdav_publish.rb", "tests/test_helper.rb", "tests/ts_davclient.rb", "davclient.gemspec"]
  s.homepage = %q{http://davclient.rubyforge.org/davclient}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Davclient", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{davclient}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Command line WebDAV client and Ruby library.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
