require 'davclient/dav-ls'
require 'davclient/dav-put'
require 'davclient/dav-propfind'

# Handle the 'dav' command line commands

class DavCLI

  def self.pwd(args)
    cwurl = WebDAV.CWURL
    if(cwurl)
      puts cwurl
    else
      puts "#{$0}: No working url set. Use 'dav cd url' to set url"
    end

  end

  def self.cd(args)
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
    if(args.size == 1 )
      WebDAV.mkcol(args[0])
    else
      puts "#{$0}: usage '#{$0} mkcol url|path"
    end
  end

  def self.delete(args)
    if(args.size == 1)
      url = WebDAV.delete(args[0])
      puts "#{$0} delete: Deleted '#{url}'"
    else
      puts "#{$0}: usage '#{$0} delete url|path"
    end
  end

  def self.options(args)
    if(args.size == 0 or args.size == 1)
      puts WebDAV.options(args[0])
    else
      puts "#{$0}: usage '#{$0} options [url]"
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
      puts "#{$0}: usage '#{$0} copy src dest"
    end
  end

  def self.print_dav_usage
    puts "usage: #{$0} COMMAND [ARGS]"
    puts ""
    puts "Available #{$0} commands:"
    puts "   ls        List files on webdav server"
    puts "   pwd       Print current working url"
    puts "   cd        Change current working url"
    puts "   propfind  Print webdav properties for url"
    puts "   mkcol     Make collection"
    puts "   options   Display webservers WebDAV options"
    puts ""
    puts "See '#{$0} COMMAND -h' for more information on a specific command."
    exit
  end

  def self.dav(args)
    command =  args[0]

    if(command == "-h" or command =~ /help/ or command =~ /\?/) then
      print_dav_usage
    end

    if(command == "-v" or command =~ /version/ ) then
      puts "#{$0} version " + WebDAV.version
      exit
    end

    args = args[1..100]
    case command
      when "ls" then
        LsCLI.ls(args)
      when "pwd"
        pwd(args)
      when "cd"
        cd(args)
      when "cp"
        cp(args)
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
      when "propfind"
        propfind(args)
      when "props"
        propfind(args)
      when "options"
        options(args)
      else
        puts "Unknown command :'" + command + "'"
        print_usage
      end
  end

end
