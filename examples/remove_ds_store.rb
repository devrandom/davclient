# -*- coding: utf-8 -*-
require 'rubygems'
require 'davclient'

# Remove all resources (files) named ".DS_Store"

url = ARGV[0]

WebDAV.find(url, :recursive => true ) do | item |
  puts item.href if(item.isCollection?)
  if(item.basename == ".DS_Store")
    puts "Removing: " + item.href
    WebDAV.delete(item.href)
  end
end
