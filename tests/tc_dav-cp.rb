# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'

class TestCP < Test::Unit::TestCase

  def cp(*args)
    out, err = util_capture do
      DavCLI.cp(*args)
    end
    return [out.string, err.string]
  end

  def test_cp
    $DEBUG = false
    src = "https://vortex-dav.uio.no/brukere/thomasfl/testfile.html"
    dest = "https://vortex-dav.uio.no/brukere/thomasfl/testfile_copy.html"
    WebDAV.cp(src,dest)
    # TODO props = WebDAV.propfind(dest)
  end

  def zzzzz_test_propfind_command_line
    src = "https://vortex-dav.uio.no/brukere/thomasfl/testfile.html"
    dest = "https://vortex-dav.uio.no/brukere/thomasfl/testfile_copy.html"
    out, err = cp([src,dest])
    puts out
  end


end
