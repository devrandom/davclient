# -*- coding: utf-8 -*-
require 'test/unit'
require 'test_helper'
require 'webdavtools'

HTML = <<EOF
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Test title</title>
</head>
<body>
  <p>Test content</p>
</body>
</html>
EOF

props = <<EOF
    <v:authors xmlns:v="vrtx">
      <vrtx:values xmlns:vrtx="http://vortikal.org/xml-value-list">
        <vrtx:value>Firstname Lastname</vrtx:value>
      </vrtx:values>
    </v:authors>
    <v:resourceType xmlns:v="vrtx">article</v:resourceType>
    <v:xhtml10-type xmlns:v="vrtx">article</v:xhtml10-type>
    <v:published-date xmlns:v="vrtx">Wed, 22 Jul 2009 12:34:56 GMT</v:published-date>
    <v:userspecifiedcharacterencoding xmlns:v="vrtx">utf-8</v:userspecifiedcharacterencoding>
    <v:characterEncoding xmlns:v="vrtx">utf-8</v:characterEncoding>
EOF
PROPERTIES = props.gsub("\n","").gsub(/ +/," ")



class TestWebDAVLibPublish < Test::Unit::TestCase


  def test_publish
    url = "https://vortex-dav.uio.no/prosjekter/it-avisa/nyheter/"
    nyhet_url = url + "testnyhet_skal_slettes.html"

    WebDAV.delete(nyhet_url)
    nyhet = WebDAV.find(nyhet_url)
    assert_nil(nyhet)

    error = false
    begin
      WebDAV.publish(nyhet_url + "/", HTML, PROPERTIES )
    rescue
      error = true
    end
    assert(error)

    WebDAV.publish(nyhet_url, HTML, PROPERTIES)

    nyhet  =  WebDAV.propfind(nyhet_url)
    assert(nyhet)
    assert_equal("Test title", nyhet.title)
    assert_equal("article", nyhet.resourcetype)
    assert_equal("utf-8", nyhet.characterencoding)

  end

end
