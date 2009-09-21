# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient'
require 'davclient/davcli'
require 'test/unit'
require 'test/zentest_assertions'
require 'pathname'

class TestPutCLI < Test::Unit::TestCase

  def put(*args)
    out, err = util_capture do
      PutCLI.put(*args)
    end
    return [out.string, err.string]
  end

  def create_file(filename, content)
    File.open(filename, 'w') {|f| f.write(content) }
  end

  def setup
    @basename = "put_test.html"
    @filename = "/tmp/" + @basename
    @url = "https://vortex-dav.uio.no/brukere/thomasfl/"
    @html = "<html><head><title>Testfile</title></head><body><h1>Testfile</h1></body></html>"
    create_file(@filename, @html)
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
    assert_equal @html, WebDAV.get(@url + @basename)

    # dav put /tmp/filename http://url/collection/
    WebDAV.delete(@url + @basename)
    out, err = put([@filename,@url])
    assert_equal @html, WebDAV.get(@url + @basename)

    # dav put /tmp/filename http://url/collection/remote-filename
    WebDAV.delete(@url + @basename)
    out, err = put([@filename,@url + @basename])
    assert_equal @html, WebDAV.get(@url + @basename)

    # dav put filename
    @local_testfile = "put_test.html"

    path = Pathname.new( Dir.getwd())
    @local_testfile = (path + @local_testfile).to_s
    create_file(@local_testfile, @html)
    WebDAV.delete(@url + @basename)
    WebDAV.cd(@url)

    out, err = put([@filename])
    assert_equal @html, WebDAV.get(@url + @basename)

    # dav put ./filename
    @local_testfile = "put_test.html"
    @local_testfile_basename = @local_testfile
    path = Pathname.new( Dir.getwd())
    @local_testfile = (path + @local_testfile).to_s
    create_file(@local_testfile, @html)
    WebDAV.delete(@url + @local_testfile_basename)
    WebDAV.cd(@url)

    out, err = put(["./" + @local_testfile_basename])
    assert_equal @html, WebDAV.get(@url + @local_testfile_basename)
  end

  def test_put_multiple_files
    # dav put filename1 filename2 filename3 filename4
    filelist = []
    for i in 1..4 do
      filename = "put_test_" + i.to_s + ".html"
      create_file(filename, @html)
      WebDAV.delete(@url + filename )
      filelist << filename
    end

    # PutCLI.put(filelist)
    out, err = put(filelist)

    for i in 1..4 do
      filename = "put_test_" + i.to_s + ".html"
      assert_equal @html, WebDAV.get(@url + filename)
    end

  end


  def test_put_multiple_files_to_url
    # dav put filename1 filename2 filename3 filename4 https://url.com/folder/

    url = @url + "put_test/"
    WebDAV.delete(url)
    WebDAV.mkcol(url)

    filelist = []
    for i in 1..4 do
      filename = "put_test_" + i.to_s + ".html"
      create_file(filename, @html)
      filelist << filename
    end

    filelist << url

    out, err = put(filelist)

    for i in 1..4 do
      filename = "put_test_" + i.to_s + ".html"
      assert_equal @html, WebDAV.get(url + filename)
    end
  end

  def test_file_not_found

    assert_raise RuntimeError do
      PutCLI.put(["a_file_that_doesn_exists_for_sure"])
    end

  end

end
