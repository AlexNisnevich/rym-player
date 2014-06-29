#!/usr/bin/ruby

require 'rubygems'

require 'google/api_client'
require 'trollop'
require 'nokogiri'
require 'open-uri'
require 'json'

VERSION = "0.0.1"
DEVELOPER_KEY = "AIzaSyAEqNnW-eOZ0HHcLKT_DJ5lgNN2b0LgGbE"
SKIP_FILE = "skipped_albums.txt"

$done = false
$skipped = false
Inf = 1.0 / 0.0

Signal.trap("TSTP")  { cleanup() }




require 'open3'



def top_albums_by_genre(genre, page = 1)
  genre = genre.gsub(' ', '%20') rescue ""
  url = "http://rateyourmusic.com/customchart?page=#{page}&chart_type=top&type=album&year=alltime&genre_include=1&genres=#{genre}&include_child_genres=t&include=both"
  doc = Nokogiri::HTML(open(url))
  albums = doc.css('td:nth-child(3)')

  idx = 0
  albums.map {|album|
    idx += 1
    {
      '#' => idx,
      :artist => album.css('.artist').map {|x| x.text}.join(", "),
      :album => album.css('.album').text,
      :genres => album.css('.genre').map {|x| x.text}.join(", "),
      :year => album.css('span:last').text[1...-1],
      :rating => album.css('div:last b:first').text,
      :url => "http://rateyourmusic.com#{album.css('.album').first.attributes['href'].value}"
    }
  }.reject {|album_data| skip_album?(album_data)}
end

def find_youtube_video(album, artist)
  opts = Trollop::options do
    opt :q, 'Search term', :type => String
    opt :maxResults, 'Max results', :type => :int, :default => 25
  end

  client = Google::APIClient.new(:key => DEVELOPER_KEY,
                                 :authorization => nil,
                                 :application_name => 'rym-listen',
                                 :application_version => VERSION)
  youtube = client.discovered_api("youtube", "v3")

  opts[:part] = 'id,snippet'
  opts[:q] = "#{artist} #{album} full album"
  search_response = client.execute!(
    :api_method => youtube.search.list,
    :parameters => opts
  )

  videos = search_response.data.items.select {|res| res.id.kind == 'youtube#video'}

  video = videos.find {|res|
            title = res.snippet.title.downcase
            title.include?(artist.downcase) &&
                title.include?(album.downcase) &&
                title.include?('full')
          }

  video ||= videos.find {|res|
              title = res.snippet.title.downcase
              title.include?(artist.downcase) &&
                  title.include?(album.downcase) &&
                  title.include?('album')
            }

  video ||= videos.first

  video
end

def play_youtube_video(video, album_data)
  puts "\n\r"
  begin
    system "mpsyt playurl https://www.youtube.com/watch?v=#{video.id.videoId}"
  rescue SignalException
    $skipped = true
  end
end

def find_and_play_tracks(album_data)
  sleep 2
  rand = (0...8).map { (65 + rand(26)).chr }.join
  stty_params = '-ixany -icanon -echo min 1 time 0 quit x'
  begin
    system "stty #{stty_params} && (echo '#{album_data[:artist]}\n\nadd all\nsave #{rand}\nplay #{rand}\nexit' && cat) | mpsyt album #{album_data[:album]}"
  rescue SignalException
    $skipped = true
  end
end

def skip_album?(album_data)
  File.readlines(SKIP_FILE).grep(Regexp.new album_data[:url]).any?
end

def skip_album_in_future(album_data)
  open(SKIP_FILE, 'a') { |f|
    f.puts album_data[:url]
  }
  puts "Added #{album_data[:url]} to skip list"
end

def startup()
  `touch #{SKIP_FILE}`
end

def cleanup()
  # kill all mpsyt processes
  system 'ps a | grep mpsyt | grep -o "[0-9][0-9]* pts" | grep -o "[0-9]*" | xargs kill -9'
  system 'stty cooked echo'
  $done = true
end

def play_genre(genre)
  begin
    (1..Inf).each do |page|
      albums = top_albums_by_genre(genre, page)
      albums.each do |album_data|
        return if $done

        puts JSON.pretty_generate(album_data)

        if false
          video = find_youtube_video(album_data[:album], album_data[:artist])

          unless video
            puts 'No Youtube video found :-('
            next
          end

          play_youtube_video video, album_data
        else
          find_and_play_tracks album_data
        end

        return if $done

        if $skipped
          puts "Skip this album in the future? (Y/N)"
          should_skip = $stdin.gets.chomp
          if should_skip.downcase == "y"
            skip_album_in_future album_data
          end
        end

        puts "\n\r\n\r"
      end
    end
  rescue SignalException
    cleanup()
  end
end

def main()
  startup()
  genre = ARGV[0]
  play_genre(genre)
end

main()
