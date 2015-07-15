#!/bin/sh

# Check if mpd is installed or not
MPD=$(dpkg -l|cut -d " " -f 3|grep "^mpd$")
if [ -z "$MPD" ]; then
  echo 'Install mpd ...'
  sudo apt-get install mpd
  echo 'Install mpd ... done'
fi

# Check if ncmpcpp is installed or not
NCMPCPP=$(dpkg -l|cut -d " " -f 3|grep "^ncmpcpp$")
if [ -z "$NCMPCPP" ]; then
  echo 'Install ncmpcpp ...'
  sudo apt-get install ncmpcpp
  echo 'Install ncmpcpp ... done'
fi

MUSIC_LIBRARY=$HOME/music_library
MPD_HOME=$HOME/.mpd
NCMPCPP_HOME=$HOME/.ncmpcpp
CONFIG_HOME=$HOME/myConfigs/mpd

mkdir -p $MPD_HOME/playlists
for f in mpd.db mpd.log mpd.pid mpd.state sticker.sqlite ; do
  echo "Checking $f ..."
  if [ ! -f $MPD_HOME/$f ]; then
    echo "Creating $MPD_HOME/$f ..."
    touch $MPD_HOME/$f
  fi
done
ln -sf $CONFIG_HOME/mpd.conf $MPD_HOME/mpd.conf

# Check if music library directory exists or not
if [ ! -d "$MUSIC_LIBRARY" ]; then
  DEFAULT_LOCATION=/softwares/iTunes_library/Music
  echo "Please input your music files location [$DEFAULT_LOCATION]: "
  read music_location
  if [ -z $music_location ]; then
    music_location=$DEFAULT_LOCATION
  fi

  ln -sf $music_location $MUSIC_LIBRARY
fi

mkdir -p $NCMPCPP_HOME
ln -sf $CONFIG_HOME/ncmpcpp.config $NCMPCPP_HOME/config
