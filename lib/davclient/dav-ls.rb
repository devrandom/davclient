# WebDav ls command line utility
# Synopsis:
#       dav ls [options][url]
#
# or standalone:
#
#     ruby dav-ls  [options][url]

require 'rubygems'
require 'davclient'
require 'optparse'

class LsCLI

  def self.ls(args)
    options = read_options(args)
    url = args[0]
    tmp_cwurl = WebDAV.CWURL
    if(not url)then
      url = WebDAV.CWURL
      if(not url)then
        puts "#{$0} ls: no current working url"
        puts "Usage: Use '#{$0} cd [url|dir] to set current working url"
        exit
      end
    else
      WebDAV.cd(url)
    end

    url = WebDAV.CWURL
    names = []
    items_data = { }
#    previous_path = ""

    WebDAV.find(url, :recursive => false ) do |item|
      if(options[:showUrl])then
        puts item.href

      elsif(options[:longFormat])
        locked = item.search("d:lockdiscovery").search("d:owner").inner_text
        items_data.merge!(item.basename => [item.href,
                                            locked,
                                            item.getlastmodified,
                                            item.getcontentlength])

      else
        # Collect all names in a folder and show them with multiple columns

        name = item.basename
        if(item.isCollection?)
          path = item.href.sub(/#{name}\/$/,"")
        else
          path = item.href.sub(/#{name}$/,"")
        end

        name +=  "/" if item.isCollection?

        # puts name.ljust(35) + path
        names << name
      end
    end

    if(options[:oneColumn])
      puts names.sort.join("\n")

    elsif(options[:longFormat])
      max_key_size = max_string_size(items_data.keys)
      items_data.keys.sort.each do |key|
        locked = ""
        locked = "Locked by: " + items_data[key][1] if(items_data[key][1] != "")
        puts key.ljust(max_key_size) + "  " + items_data[key][2] +
          "  " + items_data[key][3].rjust(12) +
          "  " + locked
      end

    else
      multicolumn_print(names.sort)
    end

    # Restore CWURL
    WebDAV.cd(tmp_cwurl)
  end

  private

  def self.read_options(args)
    options = {}

    optparse = OptionParser.new do|opts|
      opts.banner = "Usage: #{$0} ls [options] url"

      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit
      end

      options[:longFormat] = false
      opts.on( '-l', '--long',"List in long format" ) do
        options[:longFormat] = true
      end

      options[:showUrl] = false
      opts.on('-u', '--url',"Include full url in names.") do
        options[:showUrl] = true
      end


      options[:oneColumn] = false
      opts.on( '-1', "Force output to be one entry per line" ) do
        options[:oneColumn] = true
      end


    end

    begin
      optparse.parse! args
    rescue
      puts "Error: " + $!
      puts optparse
      exit
    end

    return options
  end


  # Used to make adjust to number of columns to terminal size
  # when printing names of files and folders
  def self.terminal_size
    `stty size`.split.map { |x| x.to_i }.reverse
  end

  def self.max_string_size(string_array)
    return string_array.max  {|a,b| a.length <=> b.length }.size
  end


  # Spread output across multiple columns like unix ls does.
  def self.multicolumn_print(files)
    if(files.size == 0)
      return
    end
    terminal_width, terminal_height = terminal_size()
    max_filename_size = max_string_size(files)
    columns = terminal_width / max_filename_size
    column_width = max_filename_size + 2
    row_size = (files.size.to_f / columns.to_f).ceil

    row_size.times do |row_number|
      columns.times do |column_number|
        filename = files[row_number+(column_number*row_size)].to_s + ""
        print filename.ljust(column_width)
      end
      print "\n"
    end

  end

end

# Make this file an executable script
if $0 == __FILE__
  LsCLI.ls(ARGV)
end
