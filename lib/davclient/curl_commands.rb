# -*- coding: utf-8 -*-

def remove_newlines(string)
  string.gsub("\n","").gsub(/ +/," ") + " "
end

# Templates for curl commands:
curl_propfind_cmd = <<EOF
#{$curl}
  --request PROPFIND
  --header 'Content-Type: text/xml; charset="utf-8"'
  --header "Depth: 1"
  --data-ascii '<?xml version="1.0" encoding="utf-8"?>
      <DAV:propfind xmlns:DAV="DAV:"><DAV:allprop/></DAV:propfind>'
  --netrc
EOF
CURL_PROPFIND = remove_newlines(curl_propfind_cmd)

curl_proppatch_cmd = <<EOF
#{$curl}
  --request PROPPATCH
  --header 'Content-Type: text/xml; charset="utf-8"'
  --header "Depth: 1"
  --data-ascii '<?xml version="1.0"?>
      <d:propertyupdate xmlns:d="DAV:" xmlns:v="vrtx">
        <d:set>
          <d:prop>
            <!--property-and-value-->
          </d:prop>
        </d:set>
      </d:propertyupdate>'
  --netrc
EOF
CURL_PROPPATCH = remove_newlines(curl_proppatch_cmd)

curl_delete_cmd = <<EOF
#{$curl}
  --request DELETE
  --header 'Content-Type: text/xml; charset="utf-8"'
  --netrc
EOF
CURL_DELETE = remove_newlines(curl_delete_cmd)

curl_mkcol_cmd = <<EOF
#{$curl}
  --request MKCOL
  --header 'Content-Type: text/xml; charset="utf-8"'
  --netrc
EOF
CURL_MKCOL = remove_newlines(curl_mkcol_cmd)
