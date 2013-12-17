#!/bin/sh

# Please disable mpd as system service first:
# sudo service mpd stop
# sudo update-rc.d mpd disable

cd
mkdir -p .mpd/playlists
gunzip -c /usr/share/doc/mpd/examples/mpd.conf.gz > ~/.mpd/mpd.conf
touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpdstate,sticker.sqlite}

