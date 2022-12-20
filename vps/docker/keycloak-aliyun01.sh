#!/usr/bin/env bash

export DBPWD=$(awk -F "=" '/POSTGRES_KEYCLOAK/ {print $2}' /root/.my.pwd.cnf)
export ADMINPWD=$(awk -F "=" '/KEYCLOAK_ADMIN_PASSWORD/ {print $2}' /root/.my.pwd.cnf)

cd ~/git/myDocker/keycloak/aliyun01
docker-compose -p keycloak "$@"
