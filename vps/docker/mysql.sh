#!/bin/sh

docker run -d -p 3307:3306 \
  --name mysql \
  --restart unless-stopped \
  -v /var/lib/mysql-data:/var/lib/mysql \
  -v /var/lib/mysql-conf:/etc/mysql/mysql.conf.d \
  -e MYSQL_ROOT_PASSWORD=u92XGFuk5v8VCp5J \
  mysql:5.7

