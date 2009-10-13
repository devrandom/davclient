# -*- coding: utf-8 -*-
require 'test_helper'
require 'rubygems'
require 'test/unit'
require 'davclient/util'
require 'davclient/curl_commands'

$cmd = <<EOF
curl  --user thomasfl   --request PROPFIND --header 'Content-Type: text/xml; charset="utf-8"' --header "Depth: 1" --data-ascii '<?xml version="1.0" encoding="utf-8"?><DAV:propfind xmlns:DAV="DAV:"><DAV:allprop/></DAV:propfind>'  "https://vortex-dav.uio.no/brukere/thomasfl/testseminar/"
EOF

class TestUtil < Test::Unit::TestCase

  def test_extract_host
    assert_equal "host.host.com", DavClient.exctract_host("https://host.host.com/lots-of-rubbish")
    assert_equal "host.host.com", DavClient.exctract_host("http://host.host.com?lots-of-rubbish")
    assert_equal nil, DavClient.exctract_host("//not-an-url")
  end

  # Interactiv tests
  def zzz_test_01_password_prompt
    $username = nil
    $password = nil
    DavClient.prompt_for_username_and_password("host.host.com")
    assert $username
    assert $password
  end

  def zzz_test_02_spawn_curl
    result = DavClient.spawn_curl($cmd, $password)
    assert result =~ /d:multistatus/
    result = DavClient.spawn_curl($cmd, "feil")
    assert result =~ /401 Unauthorized/
    cmd = $cmd.sub("--user thomasfl","--netrc")
    result = DavClient.spawn_curl(cmd, nil)
    assert result =~ /d:multistatus/
  end

end
