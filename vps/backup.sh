#!/bin/bash

TARGET_PATH=
if [ -z "$1" ]; then
  TARGET_PATH=$HOME/work/vps/backup
else
  TARGET_PATH=$1
  if [ ! -d "$TARGET_PATH" ]; then
    echo "$TARGET_PATH is not a valid path!"
    exit
  fi
fi

# Backup MySql database backup files from vps01
echo 'Backup mysql databases...'
rsync -azPv root@vps01:/var/vmail/backup/mysql "$TARGET_PATH"/vps01

# Backup let's encrypt certificates from vps01
echo "Backup let's encrypt certificates..."
rsync -azPv root@vps01:/etc/letsencrypt "$TARGET_PATH"/vps01/etc

# Backup Nginx setting files from vps01
echo 'Backup Nginx settings...'
rsync -azPv root@vps01:/etc/nginx "$TARGET_PATH"/vps01/etc

# Backup Artifactory backup files from aliyun01
echo 'Backup Artifactory files...'
rsync -azPv root@aliyun01:/var/opt/jfrog/artifactory/backup "$TARGET_PATH"/aliyun01/artifactory

# Backup Jenkins backup files from vps01
echo 'Backup Jenkins files...'
rsync -azPv root@vps01:/var/lib/jenkins/backup "$TARGET_PATH"/aliyun01/jenkins

# Backup Gitea backup files from vps01
echo 'Backup Gitea...'
rsync -azPv root@vps01:/var/lib/gitea "$TARGET_PATH"/aliyun01/gitea
