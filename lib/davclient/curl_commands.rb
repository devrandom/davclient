# -*- coding: utf-8 -*-

#
# Templates for curl commands
#

# Used to improve readability of curl commands that always
# needs to be on one line
def remove_newlines(string)
  string.gsub("\n","").gsub(/ +/," ") + " "
end

# Templates for curl commands:
curl_propfind_cmd = <<EOF
  --request PROPFIND
  --max-redirs 1
  --header 'Content-Type: text/xml; charset="utf-8"'
  --header "Depth: 1"
  --data-ascii '<?xml version="1.0" encoding="utf-8"?>
      <DAV:propfind xmlns:DAV="DAV:"><DAV:allprop/></DAV:propfind>'
EOF
CURL_PROPFIND = remove_newlines(curl_propfind_cmd)

curl_proppatch_cmd = <<EOF
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
EOF
CURL_PROPPATCH = remove_newlines(curl_proppatch_cmd)

curl_delete_cmd = <<EOF
  --request DELETE
  --header 'Content-Type: text/xml; charset="utf-8"'
EOF
CURL_DELETE = remove_newlines(curl_delete_cmd)

curl_mkcol_cmd = <<EOF
  --request MKCOL
  --header 'Content-Type: text/xml; charset="utf-8"'
EOF
CURL_MKCOL = remove_newlines(curl_mkcol_cmd)

CURL_OPTIONS = "-i -X OPTIONS "

curl_copy = <<EOF
  --request COPY
  --header 'Content-Type: text/xml; charset="utf-8"'
  --header 'Destination: <!--destination-->'
EOF

CURL_COPY  = remove_newlines(curl_copy)


curl_move = <<EOF
  --request MOVE
  --header 'Content-Type: text/xml; charset="utf-8"'
  --header 'Destination: <!--destination-->'
EOF

CURL_MOVE  = remove_newlines(curl_move)

CURL_UPLOAD = "--upload-file"
