# -*- coding: utf-8 -*-
require 'rubygems'
require 'test/unit'
require 'test_helper'
require 'davclient'

$curl = "/usr/local/bin/curl"

class TestWebDAVLib < Test::Unit::TestCase

  def test_find_recursive
    count = 0
    url = "https://vortex-dav.uio.no/brukere/thomasfl/anniken_2007/sophos/"
    WebDAV.find(url, :recursive => true ) do | item |
      if(item.basename == ".DS_Store")
        count += 1
      end
    end
    assert_equal(1, count)
  end

  def test_find
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/"
    items = WebDAV.find(url)

    assert(items.size > 10 )

    items = WebDAV.find(url, :type => "collection")

    assert( items.size > 9 )
    counter = 0
    WebDAV.find(url, :type => "collection") do |item|
      counter += 1
    end
    assert(counter > 9 )

    counter = 0
    WebDAV.find(url + "2008/", :type => "collection", :recursive => true) do |item|
      counter += 1
    end
    assert(counter > 9 )
  end

  def test_get
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/2008/02/nynorsk-paa-nett.html"
    item = WebDAV.propfind(url)
    assert(item)

    content = WebDAV.get(url)
    assert( content =~ /\<html/ )

  end

  def test_mkcol
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/testcol/"

    WebDAV.delete(url)

    result = WebDAV.mkcol(url,nil)
    assert(result)
    col = WebDAV.propfind(url)
    assert(col)

    # TODO Set properties på collection

  end

  def test_propfind
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/"
    item = WebDAV.propfind(url, :xml => true)
    assert(item.class == String)
    # puts "DEBUG:: " + item

    item = WebDAV.propfind(url)
    assert(item.class != String)
    assert_equal(url, item.href)
    assert_equal("Nyheter", item.title)

    assert_nil(item.denne_finnes_virkelig_ikke)

    # Properties should be readable with minor misspellings like wrong casing
    assert(item.property("v:resourceType") ) # CamelCased
    assert(item.property("v:resourcetype") ) # Downcase

  end


end
