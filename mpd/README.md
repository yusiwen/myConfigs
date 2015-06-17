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
touch ~/.mpd/{mpd.db,mpd.log,mpd.pid,mpd.state,sticker.sqlite}
ln -sf /softwares/iTunes_library/Music ~/music_library
```

NOTE: Change `music_directory` path in `mpd.conf` file to music library.

```text
mkdir -p ~/.ncmpcpp
cd .ncmpcpp
ln -sf ~/myConfigs/mpd/ncmpcpp.config config
```

NOTE: In `ncmpcpp`, use `u` key to update library.

## Troubleshooting

Start mpd in debug mode to see error logs:

```
mpd --stdout --no-daemon --verbose ~/.mpd/mpd.conf
```

## Reference

See this [link] for further instructions.

[link]:http://crunchbang.org/forums/viewtopic.php?pid=182574

