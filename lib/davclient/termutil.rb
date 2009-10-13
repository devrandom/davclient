# require 'rubygems'
require 'termios'

# Prompt for password
# Extracted from Ian Macdonald's Ruby/Password gem.
#
# Example:
#
#      password = getc(message="Password: ", mask='*')
#      puts "It's:" + password

class TermUtil

  def self.echo(on=true, masked=false)
    term = Termios::getattr( $stdin )

    if on
      term.c_lflag |= ( Termios::ECHO | Termios::ICANON )
    else # off
      term.c_lflag &= ~Termios::ECHO
      term.c_lflag &= ~Termios::ICANON if masked
    end

    Termios::setattr( $stdin, Termios::TCSANOW, term )
  end

  def self.getc(message="Password: ", mask='*')
    # Save current buffering mode
    buffering = $stdout.sync

    # Turn off buffering
    $stdout.sync = true

    begin
      echo(false, true)
      print message if message
      pw = ""

      while ( char = $stdin.getc ) != 10 # break after [Enter]
        putc mask
        pw << char
      end

    ensure
      echo true
      print "\n"
    end

    # Restore original buffering mode
    $stdout.sync = buffering

    return pw
  end

end
