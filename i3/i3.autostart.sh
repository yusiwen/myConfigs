#! /bin/sh

# DOC
# ==========
# Simple autostart file for i3-wm, you can execute it from i3 config
# file. Put this at the end:
# exec $HOME/bin/auto-start-for-i3
#
# Building this layout
# ____________________________________
# |                     |             |
# |                     |             |
# |                     |             |
# |                     |    urxvt2   |
# |                     |             |
# |                     |             |
# |       urxvt1        |_____________|
# |                     |             |
# |                     |             |
# |                     |    urxvt3   |
# |                     |             |
# |                     |             |
# |_____________________|_____________|
#
# Building a layout on another workspace switch to it with:
# i3-msg Workspace 2
#
# It may be usefull to disable mouse pointer and/or touchpad while
# layouting.
#
# Disable mouse:
# mouseID=`xinput list | grep -Eo 'Mouse\s.*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
# xinput set-prop $mouseID "Device Enabled" 0
#
# Enable mouse:
# xinput set-prop $mouseID "Device Enabled" 1
#
# Disable the touchpad:
# touchID=`xinput list | grep -Eo 'TouchPad\s*id\=[0-9]{1,2}' | grep -Eo '[0-9]{1,2}'`
# xinput set-prop $touchID "Device Enabled" 0
#
# Enable the touchpad
# xinput set-prop $touchID "Device Enabled" 1
#
# Another solution how to disable/enable
# https://github.com/deterenkelt/dotfiles/blob/master/.i3/autostart.sh

# Base on:
# https://github.com/fhaun/config-misc/blob/master/i3-stuff/auto-start-for-i3

# CODE
# ==========

i3-msg Workspace 1:Main
sleep 2

### --- urxvt1 --- ###
i3-sensible-terminal
sleep 3

### --- urxvt2 ---- ###
i3-sensible-terminal
sleep 1

# make left half bigger
i3-msg resize shrink width 10 px or 10 ppt
sleep 1

# split right half vertical
i3-msg split v
sleep 1

### --- urxvt3 --- ###
i3-sensible-terminal

exit 0
