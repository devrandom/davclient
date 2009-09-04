# -*- coding: utf-8 -*-
require 'rubygems'
require 'test/unit'
require 'test_helper'
require 'davclient'
require 'davclient/dav-cd'
require 'test/zentest_assertions'

class TestWDavCd < Test::Unit::TestCase

  def cd(args)
    out, err = util_capture do
      WebDAV.cd(args)
    end
    return [out.string, err.string]
  end

  def test_basic_cd
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/"
    out, err = cd(url)
    assert_equal url, WebDAV.CWURL
  end

  def test_pathname
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/"
    out, err = cd(url)
    assert_equal url, WebDAV.CWURL
    out, err = cd("..")
    assert_equal url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/", WebDAV.CWURL

    out, err = WebDAV.cd("../../../brukere/thomasfl/")
    assert_equal "https://vortex-dav.uio.no/brukere/thomasfl/", WebDAV.CWURL

    exception = false
    begin
      out, err = WebDAV.cd("../../../../../../")
    rescue Exception
      exception = true
    end
    assert exception, "Should have raised an exception"

  end

end
