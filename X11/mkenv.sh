#!/bin/sh

ln -sfnv $HOME/myConfigs/X11/Xresources $HOME/.Xresources
# Default color theme and font, using ../change_theme.sh to change themes
ln -sfnv $HOME/myConfigs/X11/themes/jellybeans.xresources $HOME/.Xresources.theme
ln -sfnv $HOME/myConfigs/X11/fonts/input-mono-compressed.xresources $HOME/.Xresources.font
xrdb -load $HOME/.Xresources

. $HOME/myConfigs/gfw/get_apt_proxy.sh

RXVT_PACAKGE=$(dpkg -l|cut -d " " -f 3|grep "rxvt-unicode-256color")
if [ -z "$RXVT_PACAKGE" ]; then
  echo "Installing rxvt-unicode-256color..."
  sudo apt-get $APT_PROXY install rxvt-unicode-256color
fi
