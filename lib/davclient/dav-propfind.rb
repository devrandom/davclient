# Handle 'dav propfind [URL]' command
require 'rubygems'
require 'davclient'
require 'optparse'

class PropfindCLI

  def self.propfind(args)
    options = read_options(args)

    url = args[0]
    if(not(url)) then
      url = WebDAV.CWURL
    end

    if(not(url)) then
      puts "Error: Missing mandatory url"
      puts optparse
      exit
    end

    if(options[:xml])then
      puts WebDAV.propfind(url, :xml => true)
    else

      # TODO This is experimental code in desperat need
      # of love and attention
      item = WebDAV.propfind(url)
      puts item.collection

      prev_url = nil
      WebDAV.find(url, :children => options[:children]) do | url, item |
        if(prev_url != url) then
          puts
          puts "url = " + url.to_s
          prev_url = url
        end

        name = item.prefix
        if(item.namespace)then
          name = name + "(" + item.namespace + ")"
        end
        name = name + item.name
        puts name.ljust(40) + " = '" + item.text.to_s + "'"
      end

    end

  end

  private

  def self.read_options(args)
    options = {}

    title = nil
    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: #{$0} propfind [options] url"

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end

      options[:xml] = true
      opts.on( '-p', '--pretty', "Pretty print output instead of returning xml" ) do
        options[:xml] = false
      end

      options[:children] = false
      opts.on('-c', '--children', "Show children if viewing collection (folder)") do
        options[:children] = true
      end

    end

    begin
      optparse.parse!
    rescue
      puts "Error: " + $!
      puts optparse
      exit
    end

    return options
  end

end

if $0 == __FILE__
  PropfindCLI.propfind(ARGV)
end
