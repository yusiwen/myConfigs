#!/bin/sh

docker run -d -p 3307:3306 \
  --name mysql \
  -v /var/lib/mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=u92XGFuk5v8VCp5J \
  mysql:5.7

