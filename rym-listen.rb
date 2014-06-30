#!/usr/bin/ruby

require 'rubygems'

require 'google/api_client'
require 'trollop'
require 'nokogiri'
require 'unidecoder'

require 'open-uri'
require 'json'
require 'io/console'

$done = false

[
  'constants',
  'album',
  'player',
  'tmux',
].each do |file|
  require File.dirname(__FILE__) + "/lib/#{file}.rb"
end

Signal.trap("TSTP")  { cleanup() }

def top_albums_by_genre(genre, page = 1)
  genre = genre.gsub(' ', '%20') rescue ""
  url = "http://rateyourmusic.com/customchart?page=#{page}&chart_type=top&type=album&year=alltime&genre_include=1&genres=#{genre}&include_child_genres=t&include=both"
  doc = Nokogiri::HTML(open(url))
  albums = doc.css('td:nth-child(3)')

  idx = 0
  albums.map {|albumDom|
    idx += 1
    album = Album.new
    album.num = idx
    album.title = albumDom.css('.album').text
    album.artists = albumDom.css('.artist').map {|x| x.text}
    album.genres = albumDom.css('.genre').map {|x| x.text}.join(", ")
    album.year = albumDom.css('span:last').text[1...-1]
    album.rating = albumDom.css('div:last b:first').text
    album.url = "http://rateyourmusic.com#{albumDom.css('.album').first.attributes['href'].value}"
    album
  }
end

def init()
  system "touch #{SKIP_FILE}"
  puts "\n" * $stdin.winsize[0]
end

def cleanup()
  # kill all mpsyt processes
  system 'ps a | grep mpsyt | grep -o "[0-9][0-9]* pts" | grep -o "[0-9]*" | xargs kill -9'
  system 'stty cooked echo'
  system 'tmux kill-pane -t 1'
  $done = true
  exit
end

def main()
  init()
  player = Player.new
  genre = ARGV[0]
  player.play_genre(genre)
end

main()
