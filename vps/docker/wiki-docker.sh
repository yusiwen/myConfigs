#!/usr/bin/env bash

export WIKIJS_VERSION=2.5.268
cd ~/myDocker/wiki.js
docker-compose "$@"
