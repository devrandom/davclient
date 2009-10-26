# -*- coding: utf-8 -*-
require 'rubygems'
require 'test/unit'
require 'test_helper'
require 'davclient'

$curl = "/usr/local/bin/curl"

class TestWebDAVLib < Test::Unit::TestCase

  def test_01_hpricot_extensions
    url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    test_content = "<html><head><title>title</title></head><body>one two three</body></html>"
    WebDAV.delete(url + "testcase")
    WebDAV.mkcol(url + "testcase")
    WebDAV.publish(url + "testcase/test_page.html", test_content,nil)

    webpage = nil
    WebDAV.find(url + "testcase/") do |item|
      webpage = item
    end

#    puts webpage.href
#    puts "content: " + webpage.content

    webpage.content = webpage.content.gsub(/two/,"2")

    webpage = nil
    WebDAV.find(url + "testcase/") do |item|
      webpage = item
    end
    assert webpage.content =~ /one 2 three/

  end

  def test_find
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/"
    items = WebDAV.find(url)
    assert(items.size > 10 )

    antall = items.size
    WebDAV.cd(url)
    items = WebDAV.find()
    assert_equal(antall, items.size )

    assert_raise RuntimeError do
      WebDAV.CWURL = nil
      items = WebDAV.find()
    end

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
