# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'

class TestMove < Test::Unit::TestCase

  def mv(*args)
    out, err = util_capture do
      DavCLI.mv(*args)
    end
    return [out.string, err.string]
  end

  def test_mv
    $DEBUG = false
    src = "https://vortex-dav.uio.no/brukere/thomasfl/testfile.html"
    dest = "https://vortex-dav.uio.no/brukere/thomasfl/testfile_copy.html"
    WebDAV.delete(dest)
    assert !WebDAV.exists?(dest)

    WebDAV.mv(src,dest)
    assert WebDAV.exists?(dest)
    assert !WebDAV.exists?(src)

    WebDAV.mv(dest, src)

    assert !WebDAV.exists?(dest)
    assert WebDAV.exists?(src)
  end

  def test_mv_command_line
    src = "https://vortex-dav.uio.no/brukere/thomasfl/testfile.html"
    dest = "https://vortex-dav.uio.no/brukere/thomasfl/testfile_copy.html"
    WebDAV.delete(dest)
    assert !WebDAV.exists?(dest)

    out, err = mv([src,dest])
    assert WebDAV.exists?(dest)
    assert !WebDAV.exists?(src)

    out, err = mv([dest, src])
    assert !WebDAV.exists?(dest)
    assert WebDAV.exists?(src)

  end

  def test_mv_relative
    WebDAV.cd("https://vortex-dav.uio.no/brukere/thomasfl/")

    src = "testfile.html"
    dest = "testfile.html"

    out, err = mv([src,dest])
    assert WebDAV.exists?(dest)

    out, err = mv([dest, src])
    assert WebDAV.exists?(src)
  end


end
