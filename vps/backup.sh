#!/bin/sh

TARGET_PATH=
if [ -z $1 ]; then
  TARGET_PATH=$HOME/vps/backup
else
  TARGET_PATH=$1
  if [ ! -d $TARGET_PATH ]; then
    echo "$TARGET_PATH is not a valid path!"
    exit
  fi
fi

# Backup MySql database backup files from vps01
echo 'Backup mysql databases...'
rsync -azPv root@vps01:/var/vmail/backup/mysql $TARGET_PATH

# Backup let's encrypt certificates from vps01
echo "Backup let's encrypt certificates..."
rsync -azPv root@vps01:/etc/letsencrypt $TARGET_PATH/etc

# Backup Jenkins backup files from vps01
echo 'Backup Jenkins jobs...'
rsync -azPv root@vps01:/var/lib/jenkins/backup $TARGET_PATH/jenkins

# Backup Nginx setting files from vps01
echo 'Backup Nginx settings...'
rsync -azPv root@vps01:/etc/nginx $TARGET_PATH/etc

# Backup Supervisor setting files from vps01
echo 'Backup Supervisor settings...'
rsync -azPv root@vps01:/etc/supervisor $TARGET_PATH/etc

# Backup Artifactory backup files from vps01
echo 'Backup Artifactory files...'
rsync -azPv root@vps01:/var/opt/jfrog/artifactory/backup $TARGET_PATH/artifactory
