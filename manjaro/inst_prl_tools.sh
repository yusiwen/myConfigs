#!/bin/sh

sudo ln -sf /usr/lib/systemd/scripts/ /etc/init.d
export def_sysconfdir=/etc/init.d
sudo touch /etc/X11/xorg.conf
sudo cp ./parallels-tools.service /usr/lib/systemd/system/
sudo cp ./90-prlcc.sh /etc/X11/xinit/xinitrc.d/

