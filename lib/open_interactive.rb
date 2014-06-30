
class OpenInteractive
  def self.stty_raw
    system "stty -ixany -icanon -echo min 1 time 0"
  end

  def self.stty_cooked
    system "stty cooked echo"
  end

  def self.open(command, input)
    self.stty_raw
    begin
      if input
        input = input.join("\n")
        system "(echo '#{input}' && cat) | #{command}"
      else
        system "cat | #{command}"
      end
    rescue SignalException
    end
    self.stty_cooked
  end
end
