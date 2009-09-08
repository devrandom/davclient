# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'


class TestLsCLI < Test::Unit::TestCase

  def ls(*args)
    out, err = util_capture do
      DavCLI.ls(*args)
    end
    return [out.string, err.string]
  end


  def test_basic_ls
    out, err = ls(["-a", "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2005/"])
    assert_equal(9, out.split(/\n/).size )

    assert(out =~ /^https:\/\//)
    assert_equal("", err)

    out, err = ls(["https://vortex-dav.uio.no/brukere/thomasfl/"])
    assert (not (out =~ /^http/))
  end

  def test_ls_cwurl
    out, err = ls(["-a", "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/"])
    assert_equal(7, out.split(/\n/).size )

    WebDAV.cd("https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/")
    out, err = ls(["-a"]) # If no url are given, should use the last used url
    assert_equal(7, out.split(/\n/).size )

    WebDAV.CWURL = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2008/"
    out, err = ls([])
    assert_equal(10, out.split(/\n/).size )
  end

end
