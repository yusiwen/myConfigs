#!/bin/sh

ln -sfnv $HOME/myConfigs/X11/Xresources $HOME/.Xresources
# Default color theme and font, using ../change_theme.sh to change themes
ln -sfnv $HOME/myConfigs/X11/themes/jellybeans.xresources $HOME/.Xresources.theme
ln -sfnv $HOME/myConfigs/X11/fonts/input-mono-compressed.xresources $HOME/.Xresources.font
xrdb -load $HOME/.Xresources

PROXY=""
if [ "$1" = "-p"  ]; then
  if [ -e $HOME/.apt.conf  ]; then
    PROXY="-c $HOME/.apt.conf"
    echo "$PROXY is set"
  fi
fi

RXVT_PACAKGE=$(dpkg -l|cut -d " " -f 3|grep "rxvt-unicode-256color")
if [ -z "$RXVT_PACAKGE" ]; then
  echo "Installing rxvt-unicode-256color..."
  sudo apt-get $PROXY install rxvt-unicode-256color
fi
