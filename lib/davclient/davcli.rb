require 'davclient/dav-ls'
require 'davclient/dav-put'
require 'davclient/dav-propfind'

# Handle the 'dav' command line commands

class DavCLI

  def self.print_edit_usage
    puts "Usage: #{$0} edit [url|resource-name]"
    puts
    puts "Edit remote file in editor. File is transfered back to "
    puts "server after execution of editor is ended. "
    puts
  end

  def self.edit(args)
    if(show_help?(args))
      print_edit_usage
    else
      if(args.size == 1)
        url = args[0]
        content = WebDAV.get(url)
        tmp_filename = WebDAV.tmp_folder + File.basename(url)
        File.open(tmp_filename, 'w') {|f| f.write(content) }
        system("emacs --quick -nw " + tmp_filename)
        new_content = nil
        File.open(tmp_filename, 'r') {|f| new_content = f.read() }
        WebDAV.put_string(url, new_content)
      else
        puts "Illegal arguments: " + args[1..100].join(" ")
        print_edit_usage
      end
    end
  end

  # -------------
  # put: merge this with content of dav-put.rb
  # --------------
  #####  put multiple files recursively #######
  def self.handle_directory_element(name)
    path = Pathname.new(Pathname.pwd)
    path = path + arg
    name = path.to_s
    type = File.ftype(name)

    puts "args: " + arg
    puts "file: " + name
    puts "type: " + type
  end

  def self.put_file(local_file)
    puts "To be implemented"

  end

  def self.put_folder(local_folder)
    puts "==> putting folder"
    Dir.foreach(local_folder) do |x|
      puts "Dir content: " + x.to_s
    end
  end


  ## Put function
  ##
  ## TODO:
  ##
  ##  - Handle strings:
  ##        dav put --string "test test test" dest-url|dest-filename ????
  def self.put(args)
    args.each do |arg|
      path = Pathname.new(Pathname.pwd)
      path = path + arg
      name = path.to_s
      type = File.ftype(name)

      puts "args: " + arg
      puts "file: " + name
      puts "type: " + type
      if(type == "directory")
        put_folder(name)
      end
      puts ""
    end

  end

  # TODO
  #  - Handle glob (ie *.gif) => Tell user to quote to avoid shell glob: dav get "*.html"
  def self.get(args)
    if(args.size == 1 or args.size == 2 )
      url = args[0]
      content =  WebDAV.get(url)
      filename = ""
      if(args.size == 1)
        filename = File.basename(url)
      else
        # Handle relative paths in local filenames or local dir
        path = Pathname.new(Pathname.pwd)
        path = path + args[1]
        filename = path.to_s
        if(args[1] =~ /\/$/ or args[1] =~ /\.$/)
          path = path + filename = filename + "/" + File.basename(url)
        end
      end
      File.open(filename, 'w') {|f| f.write(content) }
    else
      puts "Illegal arguments: " + args[1..100].join(" ")
      puts "#{$0}: usage '#{$0} get remote-url [local]"
    end
  end


  def self.cat(args)
    if(args.size == 1)
      url = args[0]
      puts WebDAV.get(url)
    else
      puts "Illegal arguments: " + args[1..100].join(" ")
      puts "#{$0}: usage '#{$0} cat [url|filename]"
    end
  end

  def self.show_help?(args)
    return (args.grep("-?").size > 0 or
            args.grep("-h").size > 0 or
            args.grep("--help").size > 0 )
  end

  def self.pwd(args)
    if(show_help?(args))
      puts "Usage: #{$0} pwd"
      puts ""
      puts "Print current working url."
      exit
    end
    cwurl = WebDAV.CWURL
    if(cwurl)
      puts cwurl
    else
      puts "#{$0}: No working url set. Use 'dav cd url' to set url"
    end

  end

  def self.cd(args)
    if(show_help?(args))
      puts "Usage: #{$0} cd [url|remote-path]"
      puts
      puts "Change current working working url."
      puts
      puts "Examples: "
      puts "     #{$0} cd https://www.webdav.org/"
      puts "     #{$0} cd ../test"
      puts
      exit
    end
    url = args[0]
    if(url == nil)then
      puts "#{$0} cd: Missing mandatory url."
      exit
    end
    begin
      WebDAV.cd(url)
      puts "Changing WebDAV URL to: " + WebDAV.CWURL
    rescue Exception => exception
      puts exception
    end
  end

  def self.mkcol(args)
    if(show_help?(args))
      puts "Usage: #{$0} mkcol [url|remote-path]"
      puts
      puts "Create collection (folder) on remote server."
      puts "The command 'mkdir' is an alias for 'mkcol'."
      puts
      puts "Examples: "
      puts "     #{$0} mkcol new_collection"
      puts "     #{$0} mkcol https://www.webdav.org/new_collection/"
      puts "     #{$0} mkcol ../new_collection"
      puts
      exit
    end
    if(args.size == 1 )
      if( args[0] =~ /^http/ || WebDAV.CWURL )
        WebDAV.mkcol(args[0])
      else
        puts "Error: #{$0} mkcol: No working url set. Use '#{$0} cd url' to set url."
      end
    else
      puts "#{$0}: usage '#{$0} mkcol [url|path]"
    end
  end

  def self.delete(args)
    if(show_help?(args) or args.size != 1)
      puts "Usage: #{$0} delete [url|path]"
      puts
      puts "Delete remote collection (folder) or file."
    else
      url = WebDAV.delete(args[0])
    end
  end

  def self.options(args)
    if((args.size == 0 or args.size == 1) and !show_help?(args))
      puts WebDAV.options(args[0])
    else
      puts "Usage: #{$0} options [url]"
      puts
      puts "Prints remote server options and http headers. "
    end
  end

  def self.propfind(args)
    PropfindCLI.propfind(args)
  end

  def self.ls(args)
    LsCLI.ls(args)
  end

  def self.cp(args)
    if(args.size == 2 )
      WebDAV.cp(args[0], args[1])
    else
      puts "Usage '#{$0} cp src dest"
      puts
      puts "Copy resources on remote server."
    end
  end


  def self.mv(args)
    if(args.size == 2 )
      WebDAV.mv(args[0], args[1])
    else
      puts "Usage '#{$0} copy mv dest"
      puts
      puts "Move resources on remote server."
    end
  end

  def self.print_dav_usage
    puts "usage: #{$0} COMMAND [ARGS]"
    puts ""
    puts "Available #{$0} commands:"
    puts "   ls        List files on webdav server"
    puts "   pwd       Print current working url"
    puts "   cd        Change current working url"
    puts "   cp        Copy resource"
    puts "   mv        Move resource"
    puts "   rm        Remove resource"
    puts "   cat       Print content of resource"
    puts "   mkdir     Create remote collection (directory) (mkcol alias)"
    puts "   get       Download resource"
    puts "   put       Upload local file"
    puts "   propfind  Print webdav properties for url"
    puts "   mkcol     Make collection"
    puts "   options   Display webservers WebDAV options"
    puts "   edit      Edit contents of remote file with editor"
    puts ""
    puts "See '#{$0} COMMAND -h' for more information on a specific command."
    exit
  end

  def self.dav(args)

    $0 = $0.sub(/.*\//,"").sub(/.rb$/,"")

    command =  args[0]

    if(args.size == 0 or command == "-h" or command =~ /help/ or command =~ /\?/) then
      print_dav_usage
    end

    if(command == "-v" or command =~ /version/ ) then
      puts "#{$0} version " + WebDAV.version
      exit
    end

    args = args[1..100]
    case command
      when "put" then
        PutCLI.put(args)
      when "get" then
        get(args)
      when "edit" then
        edit(args)
      when "cat" then
        cat(args)
      when "ls" then
        LsCLI.ls(args)
      when "pwd"
        pwd(args)
      when "cd"
        cd(args)
      when "cp"
        cp(args)
      when "copy"
        cp(args)
      when "mv"
        mv(args)
      when "move"
        mv(args)
      when "mkcol"
         mkcol(args)
      when "mkdir"
         mkcol(args)
      when "put"
         PutCLI.put(args)
      when "delete"
        delete(args)
      when "del"
        delete(args)
      when "rm"
        delete(args)
      when "propfind"
        propfind(args)
      when "props"
        propfind(args)
      when "options"
        options(args)
      else
        puts "Unknown command :'" + command + "'"
        print_dav_usage
      end
  end

end
