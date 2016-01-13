#!/bin/sh

ln -sfnv $HOME/myConfigs/X11/Xresources $HOME/.Xresources
xrdb -load $HOME/.Xresources
