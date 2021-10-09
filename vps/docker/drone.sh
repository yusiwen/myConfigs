#!/bin/bash

DRONE_GITEA_CLIENT_ID="$(awk -F "=" '/DRONE_GITEA_CLIENT_ID/ {print $2}' /root/.my.pwd.cnf)"
DRONE_GITEA_CLIENT_SECRET="$(awk -F "=" '/DRONE_GITEA_CLIENT_SECRET/ {print $2}' /root/.my.pwd.cnf)"
DRONE_GITEA_SERVER="https://git.yusiwen.cn"
DRONE_RPC_SECRET=$(awk -F "=" '/DRONE_RPC_SECRET/ {print $2}' /root/.my.pwd.cnf)
DRONE_SERVER_HOST="ci.yusiwen.cn"
DRONE_SERVER_PROTO="https"

docker run -d \
  --name runner \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DRONE_RPC_PROTO=${DRONE_SERVER_PROTO} \
  -e DRONE_RPC_HOST=${DRONE_SERVER_HOST} \
  -e DRONE_RPC_SECRET=${DRONE_RPC_SECRET} \
  -e DRONE_RUNNER_CAPACITY=2 \
  -e DRONE_RUNNER_NAME=${HOSTNAME} \
  drone/drone-runner-docker:latest

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
  drone/drone:latest
