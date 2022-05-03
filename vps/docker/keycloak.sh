#!/usr/bin/env bash

export DBPWD=$(awk -F "=" '/POSTGRES_KEYCLOAK/ {print $2}' /root/.my.pwd.cnf)
export ADMINPWD=$(awk -F "=" '/KEYCLOAK_ADMIN_PASSWORD/ {print $2}' /root/.my.pwd.cnf)

cd ~/myDocker/keycloak
docker-compose "$@"
