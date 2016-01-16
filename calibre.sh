#!/bin/sh

info() {
  echo "calibre.sh [-local FILENAME]"
}

web_install=false
local_file=
if [ "$#" -eq 0 ]; then
  web_install=true
elif [ "$1" = "-local" ]; then
  web_install=false
  if [ "$#" -ne 2 ]; then
    info
    eixt 0
  fi
  local_file=$2
  if [ ! -e $local_file ]; then
    echo "File '$local_file' doesn't exist!"
    exit 1
  fi
else
  info
  exit 0
fi

if [ $web_install ]; then
  sudo -v && wget -nv -O- https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py -e use_proxy=yes -e https_proxy=https://b.qypac.net:15355 | sudo https_proxy="http://b.qypac.net:15355" bash -c python -c "import sys; main=lambda:sys.stderr.write('Download failed\n'); exec(sys.stdin.read()); main()"
else
  sudo mkdir -p /opt/calibre && sudo rm -rf /opt/calibre/* && sudo tar xvf $local_file -C /opt/calibre && sudo /opt/calibre/calibre_postinstall
fi

