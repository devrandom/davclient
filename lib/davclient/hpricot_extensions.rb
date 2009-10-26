# -*- coding: utf-8 -*-
# require 'rubygems'
require 'hpricot'
require 'davclient'
require 'davclient/hpricot_extensions'

# Extensions to the Hpricot XML parser.
module Hpricot

  class Elem

    # Makes properties available as simple method calls.
    #
    # Example:
    #    print item.creationdate()
    def method_missing(method_name, *args)
      if(args.size == 0) then
        return property(method_name.to_s)
      end
      raise "Method missing"
    end

    # Resource url
    def href()
      self.at("d:href").innerText
    end

    # Returns true of resource is a collection, i.e. a folder and not a file.
    def isCollection?()
      self.at("d:collection") != nil
    end

  end


  # Get content from resources on server
  # Example:
  #    webpage = WebDAV.find("http://example.org/index.html")
  #    print "html src: " + page.content
  def content
    if(!isCollection?)
      WebDAV.get(self.at("d:href").innerText)
    end
  end

  def content=(string)
    if(!isCollection?)
      WebDAV.put_string(href,string)
    end
  end

  # Get property for resource or collection.
  # Example:
  #    page = WebDAV.find(url)
  #    print page.property("published-date")
  def property(name)

    # TODO: Make list of recognized namespace prefixes configurable

    property = property = self.at(name)
    if(property)then
      returnValue = property.innerText
      return returnValue
    end

    property = property = self.at(name.downcase)
    if(property)then
      return property.innerText
    end

    vrtx_property = self.at("v:" + name)
    if(vrtx_property)then
      return vrtx_property.innerText
    end

    vrtx_property = self.at("v:" + name.downcase)
    if(vrtx_property)then
      return vrtx_property.innerText
    end

    dav_property = self.at("d:" +name)
    if( dav_property)then
      return dav_property.innerText
    end

    dav_property = self.at("d:" +name.downcase)
    if( dav_property)then
      return dav_property.innerText
    end

    return nil
  end

  def basename
    File.basename(self.at("d:href").innerText)
  end


  # Set the items WebDAV properties. Properties must be a string with XML.
  # Example:
  #
  #    find(url) do |item|
  #       if(item.href =~ /html$/) then
  #         item.proppatch("<d:getcontenttype>text/html</d:getcontenttype>")
  #       end
  #    end
  def proppatch(properties)
    WebDAV.proppatch(href, properties)
  end

  # :stopdoc:

  # TODO: Move to vortex_lib.rb
  def dateProperty(name)
    date = self.property(name)
    if(date =~ /\dZ$/)then
      # Fix for bug in vortex:
      #
      # Some date properties are in xmlshcema datetime format, but
      # all tough the time seems to be localtime the timezone is
      # specified as Z not CEST. Fix is to set timezone and add
      # 2 hours.
      date = date.gsub(/\dZ$/," CEST")
      time = Time.parse(date)
      time = time + (60 * 60 * 2)
      return time
    end
    time = Time.parse(date)
    return time
  end


  # TODO Not used. Delete???
  def type_convert_value(value)
    if(returnValue == "true")then
      return true
    end
    if(returnValue == "false")then
      return false
    end
    # Number format???
    ## Dato format
    return returnValue
  end


  # :startdoc:

end
