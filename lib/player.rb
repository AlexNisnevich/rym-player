
class Player
  def play_youtube_video album
    video = album.find_youtube_video

    if video
      puts "\n\r"
      begin
        system "mpsyt playurl https://www.youtube.com/watch?v=#{video.id.videoId}"
      rescue SignalException
      end
    else
      puts 'No Youtube video found :-('
    end
  end

  def find_and_play_tracks album
    sleep 2
    rand = (0...8).map { (65 + rand(26)).chr }.join
    Tmux.open "mpsyt album #{album.title}"
    Tmux.send_lines [
      album.primary_artist,
      "",
      "add all",
      "save #{rand}",
      "play #{rand}",
      "exit"
    ]
  end

  def kill_current_player
    system 'ps a | grep mpsyt | grep -o "[0-9][0-9]* pts" | grep -o "[0-9]*" | xargs kill -9'
    Tmux.send_lines ['clear']
  end

  def play_genre genre
    begin
      (1..Inf).each do |page|
        albums = top_albums_by_genre(genre, page)
        albums.each do |album|
          return if $done

          puts album

          if album.skip?
            puts "skipping album ..."
          else
            find_and_play_tracks album

            return if $done

            puts "    [enter] next album    [s] next album + skip this album in the future"
            while true
              ch = $stdin.getch
              if ch == "s"
                album.skip_album_in_future
                break
              elsif ch.ord == 13 || ch.ord == 3 # Enter / Ctrl-C
                break
              elsif ch.ord == 26 # Ctrl-Z
                cleanup()
              else
                Tmux.send_key ch
              end
            end

            kill_current_player
          end

          puts "\n\r\n\r"
        end
      end
    rescue SignalException
      cleanup()
    end
  end
end
