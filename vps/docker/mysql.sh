#!/usr/bin/env bash

export MYSQL_ROOTPWD=$(awk -F "=" '/MYSQL_ROOTPWD/ {print $2}' /root/.my.pwd.cnf)

cd ~/myDocker/dbms/mysql/aliyun01
docker-compose -p mysql "$@"

