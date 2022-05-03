#!/bin/bash

export ROOTPWD=$(awk -F "=" '/POSTGRES_ROOT/ {print $2}' /root/.my.pwd.cnf)

if [ -z "$(docker network ls | grep postgres)" ]; then
  docker network create -d bridge postgres
fi

cd ~/myDocker/postgresql/aliyun02
docker-compose -p postgresql "$@"
