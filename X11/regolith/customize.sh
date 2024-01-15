#!/usr/bin/env bash

SUDO=
if [ "$OS" = 'Linux' ]; then
  if [ $EUID -ne 0 ]; then
    SUDO=sudo
  fi
fi

ILIA_CONFIG_FILE=/usr/share/regolith/i3/config.d/20_ilia

if [ ! -e "$ILIA_CONFIG_FILE" ]; then
  echo "$ILIA_CONFIG_FILE not found."
  exit 1
fi

# Application laucher
$SUDO sed -i -e "s/\$mod+\$wm.binding.launcher.app/\$alt+\$wm.binding.launcher.app/ w /dev/stdout" $ILIA_CONFIG_FILE

# Command
$SUDO sed -i -e "s/\$mod+\$wm.binding.launcher.cmd/\$alt+\$wm.binding.launcher.cmd/ w /dev/stdout" $ILIA_CONFIG_FILE
