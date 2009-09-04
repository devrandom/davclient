# -*- coding: utf-8 -*-
require 'rubygems'
require 'test/unit'
require 'davclient'
require 'davclient/dav-ls'
require 'test/zentest_assertions'
require 'test_helper'

class TestWDavLs < Test::Unit::TestCase

  # Run the 'wdav ls' command line script and capture stdin & stderr
  def ls(*args)
    out, err = util_capture do
      LsCLI.ls(args)
    end
    return [out.string, err.string]
  end


  def test_basic_ls
    out, err = ls("-a", "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/")
    assert_equal(7, out.split(/\n/).size )
    assert(out =~ /^https:\/\//)
    assert_equal("", err)

    out, err = ls("https://vortex-dav.uio.no/brukere/thomasfl/")
    assert (not (out =~ /^http/))
  end

  def test_ls_cwurl
    out, err = ls("-a", "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/")
    assert_equal(7, out.split(/\n/).size )

    WebDAV.cd("https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/")
    out, err = ls("-a") # If no url are given, should use the last used url
    assert_equal(7, out.split(/\n/).size )

    WebDAV.CWURL = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2008/"
    out, err = ls()
    assert_equal(10, out.split(/\n/).size )
  end

end
