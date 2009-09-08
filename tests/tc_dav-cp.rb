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
    WebDAV.delete(dest)
    assert !WebDAV.exists?(dest)

    WebDAV.cp(src,dest)
    assert WebDAV.exists?(dest)
  end

  def test_propfind_command_line
    src = "https://vortex-dav.uio.no/brukere/thomasfl/testfile.html"
    dest = "https://vortex-dav.uio.no/brukere/thomasfl/testfile_copy.html"
    WebDAV.delete(dest)
    assert !WebDAV.exists?(dest)

    out, err = cp([src,dest])
    assert WebDAV.exists?(dest)

    # Relative url
    WebDAV.delete(dest)
    assert !WebDAV.exists?(dest)


    WebDAV.cd("https://vortex-dav.uio.no/brukere/thomasfl/")
    dest = "testfile_copy.html"

#    puts "Siste test:"
    out, err = cp([src,dest])
    assert WebDAV.exists?(dest)
#    puts err
#    puts out
  end


end
