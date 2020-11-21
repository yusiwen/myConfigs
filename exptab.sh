#!/bin/bash

function process() {
  echo "$1"
  expand -i -t 2 "$1" > $1.tmp
  rm -f "$1"
  mv $1.tmp $1
}

export -f process
find . -type f \( -name \*.vim -o -iname \*.lua \) -exec bash -c 'process "$0"' {} \;
