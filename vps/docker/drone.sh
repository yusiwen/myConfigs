#!/usr/bin/env bash

DRONE_VERSION=2.16.0
RUNNER_VERSION=1.8.3

SERVER_TYPE=gitea

DRONE_GITEA_CLIENT_ID="$(awk -F "=" '/DRONE_GITEA_CLIENT_ID/ {print $2}' $HOME/.my.pwd.cnf)"
DRONE_GITEA_CLIENT_SECRET="$(awk -F "=" '/DRONE_GITEA_CLIENT_SECRET/ {print $2}' $HOME/.my.pwd.cnf)"
DRONE_GITEA_SERVER="https://git.yusiwen.cn"
DRONE_GITHUB_CLIENT_ID="$(awk -F "=" '/DRONE_GITHUB_CLIENT_ID/ {print $2}' $HOME/.my.pwd.cnf)"
DRONE_GITHUB_CLIENT_SECRET="$(awk -F "=" '/DRONE_GITHUB_CLIENT_SECRET/ {print $2}' $HOME/.my.pwd.cnf)"
DRONE_RPC_SECRET=$(awk -F "=" '/DRONE_RPC_SECRET/ {print $2}' $HOME/.my.pwd.cnf)
DRONE_SERVER_HOST=
DRONE_SERVER_PROTO="https"
DRONE_RUNNER_LABELS=
DRONE_RUNNER_CAPACITY=10

START_RUNNER=
START_SERVER=

function start_drone_runner() {
  echo "Starting drone runner $RUNNER_VERSION..."
  echo "DRONE_RPC_SECRET=$DRONE_RPC_SECRET"
  echo "DRONE_RUNNER_LABELS=$DRONE_RUNNER_LABELS"
  echo "DRONE_RUNNER_CAPACITY=$DRONE_RUNNER_CAPACITY"
  if [ "$SERVER_TYPE" = 'gitea' ]; then
    DRONE_SERVER_HOST="ci.yusiwen.cn"
  elif [ "$SERVER_TYPE" = 'github' ]; then
    DRONE_SERVER_HOST="ci-github.yusiwen.cn"
  else
    echo "Unsupported server type: $SERVER_TYPE"
    exit 1
  fi

  docker run -d \
    --name drone-runner-${SERVER_TYPE} \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e DRONE_RPC_PROTO=${DRONE_SERVER_PROTO} \
    -e DRONE_RPC_HOST=${DRONE_SERVER_HOST} \
    -e DRONE_RPC_SECRET=${DRONE_RPC_SECRET} \
    -e DRONE_RUNNER_CAPACITY=2 \
    -e DRONE_RUNNER_NAME=${HOSTNAME} \
    -e DRONE_RUNNER_LABELS=${DRONE_RUNNER_LABELS} \
    -e DRONE_RUNNER_CAPACITY=${DRONE_RUNNER_CAPACITY} \
    drone/drone-runner-docker:${RUNNER_VERSION}
}

function start_drone_server() {
  echo "DRONE_RPC_SECRET=$DRONE_RPC_SECRET"

  if [ "$SERVER_TYPE" = 'gitea' ]; then
    DRONE_SERVER_HOST="ci.yusiwen.cn"
    echo "Starting drone server $DRONE_VERSION for gitea..."

    echo "DRONE_GITHUB_CLIENT_ID=$DRONE_GITHUB_CLIENT_ID"
    echo "DRONE_GITHUB_CLIENT_SECRET=$DRONE_GITHUB_CLIENT_SECRET"

    docker run -d \
      --name drone \
      --restart unless-stopped \
      -p 127.0.0.1:8900:80 \
      -v /var/lib/drone:/data \
      -e DRONE_GITEA_SERVER=${DRONE_GITEA_SERVER} \
      -e DRONE_GITEA_CLIENT_ID=${DRONE_GITEA_CLIENT_ID} \
      -e DRONE_GITEA_CLIENT_SECRET=${DRONE_GITEA_CLIENT_SECRET} \
      -e DRONE_RPC_SECRET=${DRONE_RPC_SECRET} \
      -e DRONE_SERVER_HOST=${DRONE_SERVER_HOST} \
      -e DRONE_SERVER_PROTO=${DRONE_SERVER_PROTO} \
      -e DRONE_USER_CREATE=username:yusiwen,admin:true \
      -e DRONE_USER_FILTER=yusiwen \
      -e DRONE_LOGS_TEXT=true \
      -e DRONE_LOGS_PRETTY=true \
      drone/drone:${DRONE_VERSION}
  elif [ "$SERVER_TYPE" = 'github' ]; then
    DRONE_SERVER_HOST="ci-github.yusiwen.cn"
    echo "Starting drone server $DRONE_VERSION for github..."
    echo "DRONE_GITEA_CLIENT_ID=$DRONE_GITEA_CLIENT_ID"
    echo "DRONE_GITEA_CLIENT_SECRET=$DRONE_GITEA_CLIENT_SECRET"
    echo "DRONE_GITEA_SERVER=$DRONE_GITEA_SERVER"

    docker run -d \
      --name drone \
      --restart unless-stopped \
      -p 127.0.0.1:8900:80 \
      -v /var/lib/drone:/data \
      -e DRONE_GITHUB_CLIENT_ID=${DRONE_GITHUB_CLIENT_ID} \
      -e DRONE_GITHUB_CLIENT_SECRET=${DRONE_GITHUB_CLIENT_SECRET} \
      -e DRONE_RPC_SECRET=${DRONE_RPC_SECRET} \
      -e DRONE_SERVER_HOST=${DRONE_SERVER_HOST} \
      -e DRONE_SERVER_PROTO=${DRONE_SERVER_PROTO} \
      -e DRONE_USER_CREATE=username:yusiwen,admin:true \
      -e DRONE_USER_FILTER=yusiwen \
      -e DRONE_LOGS_TEXT=true \
      -e DRONE_LOGS_PRETTY=true \
      drone/drone:${DRONE_VERSION}
  else
    echo "Unsupported server type: $SERVER_TYPE"
    exit 1
  fi
  
}

function usage() {
  echo "drone.sh [-s <SERVER_TYPE:gitea>] [-r <SERVER_TYPE:gitea>] [-l <LABELS>] [-R RPC_SECRET]"
}

while getopts "R:hs:r:c:l:" opt
do
  case $opt in
    R)
      DRONE_RPC_SECRET=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
    s)
      START_SERVER=1
      SERVER_TYPE=$OPTARG
      ;;
    r)
      START_RUNNER=1
      SERVER_TYPE=$OPTARG
      ;;
    c)
      DRONE_RUNNER_CAPACITY=$OPTARG
      ;;
    l)
      DRONE_RUNNER_LABELS=$OPTARG
      ;;
    *)
      usage
      exit 0
      ;;
  esac
done

if [ $OPTIND -eq 1 ]; then
  usage
  exit 0
fi



if [ "$START_SERVER" = 1 ]; then
  start_drone_server
fi

if [ "$START_RUNNER" = 1 ]; then
  if ! [[ "$DRONE_RUNNER_CAPACITY" =~ ^[0-9]+$ ]]; then
    echo "warn: wrong runner capacity, fallback to default(10)"
    DRONE_RUNNER_CAPACITY=10
  fi
  start_drone_runner
fi
