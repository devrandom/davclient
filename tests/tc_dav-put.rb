# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'


class TestPutCLI < Test::Unit::TestCase

  def put(*args)
    out, err = util_capture do
      PutCLI.put(*args)
    end
    return [out.string, err.string]
  end

  def setup
    @basename = "put_test.html"
    @filename = "/tmp/" + @basename
    @url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    @html = "<html><head><title>Testfile</title></head><body><h1>Testfile</h1></body></html>"
    File.open(@filename, 'w') {|f| f.write(@html) }
    WebDAV.delete(@url + @basename)
  end

  def teardown
    File.delete(@filename)
  end

  def test_basic_put

    # dav put /tmp/filename
    WebDAV.delete(@url + @basename)
    WebDAV.cd(@url)
    out, err = put([@filename])
    content = WebDAV.get(@url + @basename)
    assert content == @html

    # dav put /tmp/filename http://url/collection/
    WebDAV.delete(@url + @basename)
    out, err = put([@filename,@url])
    content = WebDAV.get(@url + @basename)
    assert content == @html

    # dav put /tmp/filename http://url/collection/remote-filename
    WebDAV.delete(@url + @basename)
    out, err = put([@filename,@url + @basename])
    content = WebDAV.get(@url + @basename)
    assert content == @html

    # dav put ./filename
    @local_testfile = "./put_test.html"

    # dav put filename1 filename2 filename3 ...

  end

  def zzzzzzzz_test
    out, err = put([filename, url])
    puts out

    out, err = put([filename, url + "put_test.html"])
    # get = WebDAV.get(url)
    # puts get
  end

end
