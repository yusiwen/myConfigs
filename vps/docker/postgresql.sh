#!/bin/bash

ROOTPWD=$(awk -F "=" '/POSTGRES_ROOT/ {print $2}' /root/.my.pwd.cnf)

if [ -z "$(docker network ls | grep postgres)" ]; then
  docker network create -d bridge postgres
fi

docker run -d \
  --name postgres \
  --network postgres \
  --restart unless-stopped \
  -p 127.0.0.1:5432:5432 \
  -e POSTGRES_PASSWORD=$ROOTPWD \
  -v /var/lib/postgresql/data:/var/lib/postgresql/data \
  postgres:latest
