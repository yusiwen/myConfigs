#!/usr/bin/env bash

NETPROFILE=$(cat "$HOME/.config/netprofiles/$HOSTNAME/.current")

if [ "$NETPROFILE" != "home" ]; then
  export HTTP_PROXY="http://localhost:7890"
  export HTTPS_PROXY="http://localhost:7890"
fi

/usr/bin/calibre --detach "$@"