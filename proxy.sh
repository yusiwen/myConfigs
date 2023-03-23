#!/usr/bin/env bash

function set_proxy() {
  export HTTP_PROXY='http://localhost:7890'
  export HTTPS_PROXY='http://localhost:7890'
  export NO_PROXY='localhost,127.0.0.1,10.96.0.0/16,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24,192.168.2.0/24,192.168.3.0/24,10.1.0.0/24'
}

function unset_proxy() {
  export HTTP_PROXY=
  export HTTPS_PROXY=
  export NO_PROXY=
}

function info() {
  echo "$0 set|unset"
}

case $1 in
set) set_proxy ;;
unset) unset_proxy ;;
*)
  info ;;
esac