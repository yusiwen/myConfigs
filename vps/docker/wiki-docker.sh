#!/usr/bin/env bash

export WIKIJS_VERSION=2.5.280
cd ~/myDocker/wiki.js
docker-compose "$@"
