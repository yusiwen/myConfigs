#!/usr/bin/env bash

export ACCESSKEY=$(awk -F "=" '/MINIO_AK/ {print $2}' /root/.my.pwd.cnf)
export SECRETKEY=$(awk -F "=" '/MINIO_SK/ {print $2}' /root/.my.pwd.cnf)

cd ~/myDocker/minio
docker-compose "$@"
