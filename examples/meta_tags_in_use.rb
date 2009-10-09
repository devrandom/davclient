require 'rubygems'
require 'davclient/simple'

# Prints out content of <meta > tags found in files

def print_html_meta_elements(url)
  doc = Hpricot(get(url))
  if(doc.search("//meta").size > 0 )

    puts url
    doc.search("//meta").each do |elem|
      if(elem.attributes.key?("name") )
        print " Name: " + elem.attributes["name"].ljust(30)
      end
      if(elem.attributes.key?("content") )
        print " Content: " + elem.attributes["content"]
      end
      puts
    end
    puts
  end
end


cd "https://www-dav.jus.uio.no/it/"

find :recursive => true do |item|
  url =  item.href.to_s
  if(url =~ /htm?|\.xml$/ )
    print_html_meta_elements(url)
  end

end
