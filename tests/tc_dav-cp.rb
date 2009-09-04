# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient/dav-propfind'
require 'test/unit'
require 'test/zentest_assertions'

class TestCP < Test::Unit::TestCase

  def cp(*args)
    out, err = util_capture do
      CpCLI.cp(*args)
    end
    return [out.string, err.string]
  end

  def test_cp
    $DEBUG = false
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    props = WebDAV.cp(url)
    assert props
  end

  def test_propfind_command_line
    url1 = "https://vortex-dav.uio.no/brukere/thomasfl/pay/"
    url2 = "https://vortex-dav.uio.no/brukere/thomasfl/pay/"
    # out, err = props(["--xml", url])
    out, err = cp([url])
    puts out
  end


end
