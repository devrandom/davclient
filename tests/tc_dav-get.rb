# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'

class TestGetCLI < Test::Unit::TestCase

  def get(*args)
    out, err = util_capture do
      DavCLI.get(*args)
    end
    return [out.string, err.string]
  end

  def create_file(filename, content)
    File.open(filename, 'w') {|f| f.write(content) }
  end

  def setup
    @basename = "get_test.html"
    @filename = "/tmp/" + @basename
    @url = "https://vortex-dav.uio.no/brukere/thomasfl/get_test/"
    @html = "<html><head><title>Testfile</title></head><body><h1>Testfile</h1></body></html>"
    create_file(@filename, @html)

    WebDAV.delete(@url)
    WebDAV.mkcol(@url)
    WebDAV.cd(@url)

    for i in 1..4 do
      filename = "get_test_" + i.to_s + ".html"
      PutCLI.put([@filename, @url + filename])
    end

  end

  def teardown
    File.delete(@filename)
    # WebDAV.delete(@url)
    WebDAV.cd("https://vortex-dav.uio.no/brukere/thomasfl/")
  end

  def test_basic_get
    # dav get filename
    # assert_equal @html, WebDAV.get(@url + @basename)
    WebDAV.cd(@url)
    # out, err = get(["get_test_1.html"])
    `rm get_*.html 2> /dev/null`
    DavCLI.get(["get_test_1.html"])
    number_of_files = `ls -1 get_test*.html|wc -l`.to_i
    assert_equal 1, number_of_files

    `rm get_*.html 2> /dev/null`
    DavCLI.get(["get_test_1.html", "get_test_2.html"])
    number_of_files = `ls -1 get_test*.html|wc -l`.to_i
    assert_equal 2, number_of_files

  end

end
