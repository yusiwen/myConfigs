#!/bin/sh

ln -sfnv $HOME/myConfigs/X11/Xresources $HOME/.Xresources
# Default color theme and font, using ../change_theme.sh to change themes
ln -sfnv $HOME/myConfigs/X11/themes/jellybeans.xresources $HOME/.Xresources.theme
ln -sfnv $HOME/myConfigs/X11/fonts/input-mono-compressed.xresources $HOME/.Xresources.font
xrdb -load $HOME/.Xresources
