# -*- coding: utf-8 -*-
require 'test/unit'
require 'test_helper'
require 'webdavtools'
require 'webdavtools/wdav_cd'
require 'webdavtools/wdav_ls'
require 'test/zentest_assertions'

class TestWDavCd < Test::Unit::TestCase

  # Run the wdav_ls command line script and capture stdio
  def cd(*args)
    out, err = util_capture do
      WDav.cd(args)
    end
    return [out.string, err.string]
  end

  def test_basic_cd
    out, err = cd("https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2006/")
    # puts "DEBUG: " + out
    assert out =~ /Set WebDAV/
  end

end
