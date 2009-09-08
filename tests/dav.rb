# -*- coding: utf-8 -*-

# This script is used to execute the 'dav' command line utility
# without re-installing the ruby gem

require 'test_helper'
require 'rubygems'
require 'davclient'
require 'davclient/davcli'

DavCLI.dav(ARGV)

