
class Tmux
  def self.num_panes
    `tmux list-panes | wc -l`.to_i
  end

  def self.open(command)
    # ensure there are two panes
    if self.num_panes < 2
      system "tmux split-window -h"
      system "tmux select-pane -t 0"
    end

    begin
      system "tmux send-keys -t 1 '#{command.to_ascii}' Enter"
    rescue SignalException
      system "tmux send-keys -t 1 C-C"
    end
  end

  def self.send_lines(lines)
    lines.each do |line|
      system "tmux send-keys -t 1 '#{line.to_ascii}' Enter"
    end
  end

  def self.send_key(key)
    case key.ord
    when 0..30
      # control character - do not send
    when 32
      system "tmux send-keys -t 1 Space"
    when 65
      system "tmux send-keys -t 1 Up"
    when 66
      system "tmux send-keys -t 1 Down"
    when 67
      system "tmux send-keys -t 1 Right"
    when 68
      system "tmux send-keys -t 1 Left"
    else
      system "tmux send-keys -t 1 #{key}"
    end
  end
end
