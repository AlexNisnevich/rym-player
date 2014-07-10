#!/usr/bin/ruby

require 'rubygems'

require 'google/api_client'
require 'trollop'
require 'nokogiri'
require 'unidecoder'

require 'open-uri'
require 'json'
require 'io/console'
require 'optparse'

[
  'album',
  'constants',
  'player',
  'options',
  'tmux'
].each do |file|
  require File.dirname(__FILE__) + "/lib/#{file}.rb"
end

Signal.trap("TSTP")  { cleanup() }

def init
  system "touch #{SKIP_FILE}"
  puts "\n" * $stdin.winsize[0]
end

def cleanup
  # kill all mpsyt processes
  system 'ps a | grep mpsyt | grep -o "[0-9][0-9]* pts" | grep -o "[0-9]*" | xargs kill -9'
  system 'stty cooked echo'
  system 'tmux kill-pane -t 1'
  exit
end

def main
  options = Options.parse ARGV

  init()
  player = Player.new options
  player.play
end

main()
