MPD
===

Configuration for mpd and ncmpcpp.

## Installation
```
sudo apt-add-repository ppa:gmpc-trunk/mpd-trunk
sudo apt-get update
sudo apt-get install mpd ncmpcpp
```
## Disable mpd system service
Make mpd as an user service, not a system-wide service.
Start mpd in i3-wm session startup. see `i3/config`.
```
sudo service mpd stop
sudo update-rc.d mpd disable
```

## Configurations
```
mkdir -p ~/.mpd/playlists
cp ~/myConfigs/mpd/mpd.conf ~/.mpd/
touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpdstate,sticker.sqlite}
```
NOTE: Change `music_directory` path in `mpd.conf` file to music library.

## Reference
See this [link] for further instructions.

[link]:http://crunchbang.org/forums/viewtopic.php?pid=182574

