#!/bin/sh

CONFIG_HOME=$HOME/myConfigs/i3

I3_HOME=$HOME/.i3
[ ! -d $I3_HOME ] && mkdir -p $I3_HOME
ln -sf $CONFIG_HOME/_config $I3_HOME/_config
ln -sf $CONFIG_HOME/i3blocks/i3blocks.conf $I3_HOME/i3blocks.conf

DUNST_HOME=$HOME/.config/dunst
[ ! -d $DUNST_HOME ] && mkdir -p $DUNST_HOME
ln -sf $CONFIG_HOME/dunst/dunstrc $DUNST_HOME/dunstrc

ln -sf $CONFIG_HOME/i3bang/i3bang.rb $HOME/bin/i3bang
i3bang

sudo cp $CONFIG_HOME/xsessions/i3.desktop /usr/share/xsessions/i3.desktop
