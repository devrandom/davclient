# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'test/unit'
require 'test/zentest_assertions'

class TestMkcolCLI < Test::Unit::TestCase

  def cd(args)
    out, err = util_capture do
      WebDAV.cd(args)
    end
    return [out.string, err.string]
  end

  def mkcol(*args)
    out, err = util_capture do
      WebDAV.mkcol(args)
    end
    return [out.string, err.string]
  end

  def test_basic_mkcol
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    out, err = cd(url)
    new_url = url + "davclient_test_folder/"

    props = WebDAV.propfind(new_url, :xml => true)
    if(props)
      WebDAV.delete(new_url)
    end

    WebDAV.mkcol(new_url)
    props = WebDAV.propfind(new_url, :xml => true)
    assert props
  end

  def test_relative_url
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    out, err = cd(url)

    new_url = url + "davclient_test_folder/"

    props = WebDAV.propfind(new_url, :xml => true)
    if(props)
      WebDAV.delete(new_url)
    end
    props = WebDAV.propfind(new_url, :xml => true)
    assert_nil props

    WebDAV.mkcol("davclient_test_folder")

    props = WebDAV.propfind(new_url, :xml => true)
    assert props

    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    out, err = cd(url)
    
  end


end
