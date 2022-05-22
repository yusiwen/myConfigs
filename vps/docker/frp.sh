#!/usr/bin/env bash

function server() {
  cd ~/myDocker/frp/server
  docker-compose -p frp-server "$@"
}

function client() {
  cd ~/myDocker/frp/client
  docker-compose -p frp-client "$@"
}

if [ "$1" == 'server' ]; then
  server "${@:2}"
elif [ "$1" == 'client' ]; then
  client "${@:2}"
else
  echo 'frp.sh [server|client] up|down OPTIONS'
fi