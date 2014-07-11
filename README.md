# rym-player

**rym-player** is a command-line music player for Linux. It plays the highest-rated albums on [RateYourMusic](http://rateyourmusic.com/) one by one according to a query. While an album are being played, you can see the tracklist and navigate between tracks. After an album is played, you can choose to ignore it in the future. 

## Installation

rym-player requires Ruby 1.9+, tmux, [mps-youtube](https://github.com/np1/mps-youtube), and [mplayer](http://www.mplayerhq.hu/).

On Ubuntu and other Debian-based distros, assuming you have Bundler installed, you can install rym-player with:

```
sudo apt-get install python3-pip mplayer tmux
sudo pip3 install mps-youtube
bundle install
```

I have only tested rym-player on Ubuntu and LMDE. It should work on most Linux distros out of the box. I imagine that one could get it working on OS X as well, but I make no promises there.

## Running

Run rym-player inside of tmux:
```
tmux
ruby ./rym-player.rb [options]
```

The available options are:
```
    -g, --genre [GENRE]              Limit search to the given genre
    -y, --year [YEAR]                Limit search to the given year
    -c, --country [COUNTRY]          Limit search to the given country
    -h, --help                       Show this message
    -v, --version                    Show version
```

## Song Notifications

If you have [libnotify](https://wiki.archlinux.org/index.php/Desktop_notifications) installed and configured, you can receive a desktop notification as each track begins playing.

To set up song notifications, download [my branch of mps-youtube](https://github.com/AlexNisnevich/mps-youtube) and install it with 
```
sudo pip3 install -e [path to mps-youtube]
```
Then set up song notifications with:
```
mpsyt set notifier "ruby [path to rym-player]/notifier.rb", quit
```