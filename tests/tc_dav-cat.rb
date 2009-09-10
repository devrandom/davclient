# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'


class TestDavCat < Test::Unit::TestCase

  def cat(*args)
    out, err = util_capture do
      DavCLI.cat(*args)
    end
    return [out.string, err.string]
  end

  def test_basic_cat
    url = "https://vortex-dav.uio.no/brukere/thomasfl/testfile.html"
    content = WebDAV.get(url)

    out, err = cat([url])
    assert_equal  content + "\n", out
  end

  def test_relative_urls
    WebDAV.cd("https://vortex-dav.uio.no/brukere/thomasfl/")
    content = WebDAV.get("testfile.html")
    assert content
  end

end
