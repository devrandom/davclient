require 'rubygems'
require 'davclient/simple'

# Prints out content of <meta > tags found in files

def print_html_meta_elements(url)
  doc = Hpricot(get(url))
  if(doc.search("//meta").size > 0 )
    puts "  <tr>"
    puts "    <td><b>URL:</td><td><b>#{url}</b></td>"
    puts "  </tr>"
    # puts url
    doc.search("//meta").each do |elem|
      puts "  <tr>"
      name,content = ""
      if(elem.attributes.key?("name") )
        name = elem.attributes["name"]
      end
      if(elem.attributes.key?("content") )
        content =  elem.attributes["content"]
      end
      puts "    <td>#{name}</td><td>#{content}</td>"
      puts "  </tr>"
    end
    puts
  end
end



def print_html_meta_elements_as_plaintext(url)
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

puts "<table>"
puts "  <tr>"
puts "    <td><b>Meta- name</td><td><b>Meta-content</b></td>"
puts "  </tr>"

find :recursive => true do |item|
  url =  item.href.to_s
  if(url =~ /htm?|\.xml$/ )
    print_html_meta_elements(url)
  end
end

puts "</table>"
