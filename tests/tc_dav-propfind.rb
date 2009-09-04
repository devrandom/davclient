# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient/dav-propfind'
require 'test/unit'
require 'test/zentest_assertions'

class TestPropfind < Test::Unit::TestCase

  def props(*args)
    out, err = util_capture do
      PropfindCLI.propfind(*args)
    end
    return [out.string, err.string]
  end

  def test_propfind_library_call
    $DEBUG = false
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    props = WebDAV.propfind(url)
    assert props
  end

  def test_propfind_command_line
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    # out, err = props(["--xml", url])
    out, err = props([url])
    puts out
  end


end
