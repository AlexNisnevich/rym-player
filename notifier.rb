#!/bin/ruby
artist, title = ARGV[0].split('-').map(&:strip)
unless title
	title = artist
	artist = ""
end 
system "notify-send '#{title}' '#{artist}' --icon=sound"