#!/bin/sh

APT_PROXY=""
if [ "$1" = "-p"  ]; then
  if [ -e $HOME/.apt.conf  ]; then
    APT_PROXY="-c $HOME/.apt.conf"
    echo "APT_PROXY is set"
  fi
fi

#export APT_PROXY
