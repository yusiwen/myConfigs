#!/bin/bash

export SONARPWD=$(awk -F "=" '/POSTGRES_SONAR/ {print $2}' /root/.my.pwd.cnf)

cd ~/myDocker/sonarqube
docker-compose "$@"

