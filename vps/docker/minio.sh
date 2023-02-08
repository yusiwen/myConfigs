#!/usr/bin/env bash

export ACCESSKEY=$(pass share.yusiwen.cn/access_key)
export SECRETKEY=$(pass share.yusiwen.cn/secret_key)

cd ~/myDocker/minio
docker-compose "$@"
