
class Player
  def init
    `touch #{SKIP_FILE}`
  end

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
    OpenInteractive.open("mpsyt album #{album.title}", [
      album.primary_artist,
      "",
      "add all",
      "save #{rand}",
      "play #{rand}",
      "exit"
    ])
  end

  def play_genre genre
    begin
      (1..Inf).each do |page|
        albums = top_albums_by_genre(genre, page)
        albums.each do |album|
          return if $done

          puts album

          if false
            play_youtube_video album
          else
            find_and_play_tracks album
          end

          return if $done

          puts "Skip this album in the future? (Y/N)"
          should_skip = $stdin.gets.chomp
          if should_skip.downcase == "y"
            album.skip_album_in_future
          end

          puts "\n\r\n\r"
        end
      end
    rescue SignalException
      cleanup()
    end
  end
end
