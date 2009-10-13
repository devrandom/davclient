require 'rubygems'
require 'davclient/simple'

# Simple utility to extract all meta tags in use by html files

def print_meta_elements(url)
  doc = Hpricot(get(url))
  if(doc.search("//meta").size > 0 )
    doc.search("//meta").each do |elem|
      name,content = ""
      if(elem.attributes.key?("name") )
        name = elem.attributes["name"]
      end
      if(elem.attributes.key?("content") )
        content =  elem.attributes["content"]
      end
      puts "#{url}\t#{name}\t#{content}"
    end
  end
end


url = ARGV[0]
if(!url)
  puts "Missing url"
  exit
end

cd url

find :recursive => false do |item|
  url =  item.href.to_s
  if(url =~ /htm?|\.xml$/ )
    print_meta_elements(url)
  end
end
