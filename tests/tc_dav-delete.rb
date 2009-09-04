# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'test/unit'
require 'test/zentest_assertions'

class TestDelete < Test::Unit::TestCase

  def test_basic_delete
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    WebDAV.cd(url)

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

    assert_equal url, WebDAV.CWURL

    WebDAV.delete("davclient_test_folder")
    props = WebDAV.propfind(new_url, :xml => true)
    assert_nil props

  end


end
