#!/bin/bash

TARGET_PATH=
if [ -z "$1" ]; then
  TARGET_PATH=$HOME/work/vps/backup
else
  TARGET_PATH=$1
fi

if [ ! -d "$TARGET_PATH" ]; then
  mkdir -p "$TARGET_PATH"
  mkdir -p "$TARGET_PATH"/vps01
  mkdir -p "$TARGET_PATH"/vps03
  mkdir -p "$TARGET_PATH"/aliyun01
fi

# Backup MySql database backup files from vps01
echo '(vps01)Backup mysql databases...'
rsync -azPv root@vps01:/var/vmail/backup/mysql "$TARGET_PATH"/vps01

# Backup let's encrypt certificates from vps01
echo "(vps01)Backup let's encrypt certificates..."
rsync -azPv root@vps01:/etc/letsencrypt "$TARGET_PATH"/vps01/etc

# Backup Nginx setting files from vps01
echo '(vps01)Backup Nginx settings...'
rsync -azPv root@vps01:/etc/nginx "$TARGET_PATH"/vps01/etc

# Backup shadowsocks-libev setting files from vps03
echo '(vps03)Backup shadowsocks-libev settings...'
rsync -azPv root@vps03:/etc/shadowsocks-libev "$TARGET_PATH"/vps03/etc

# Backup MySql database backup files from aliyun01
echo '(aliyun01)Backup mysql databases...'
rsync -azPv root@aliyun01:/var/lib/mysql/backup/mysql "$TARGET_PATH"/aliyun01

# Backup let's encrypt certificates from aliyun01
echo "(aliyun01)Backup let's encrypt certificates..."
rsync -azPv root@aliyun01:/etc/letsencrypt "$TARGET_PATH"/aliyun01/etc

# Backup Nginx setting files from aliyun01
echo '(aliyun01)Backup Nginx settings...'
rsync -azPv root@aliyun01:/etc/nginx "$TARGET_PATH"/aliyun01/etc

# Backup Artifactory backup files from aliyun01
echo '(aliyun01)Backup Artifactory files...'
rsync -azPv root@aliyun01:/var/opt/jfrog/artifactory/backup "$TARGET_PATH"/aliyun01/artifactory

# Backup Jenkins backup files from vps01
echo '(aliyun01)Backup Jenkins files...'
rsync -azPv root@aliyun01:/var/lib/jenkins/backup "$TARGET_PATH"/aliyun01/jenkins

# Backup Gitea backup files from vps01
echo '(aliyun01)Backup Gitea...'
rsync -azPv root@aliyun01:/var/lib/gitea "$TARGET_PATH"/aliyun01/gitea
