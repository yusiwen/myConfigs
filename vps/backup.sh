#!/bin/sh

# Backup MySql database backup files from vps01
echo 'Backup mysql databases...'
rsync -azPv root@vps01:/var/vmail/backup/mysql $HOME/vps/backup/mysql

# Backup let's encrypt certificates from vps01
echo "Backup let's encrypt certificates..."
rsync -azPv root@vps01:/etc/letsencrypt $HOME/vps/backup/etc

# Backup Jenkins backup files from vps01
echo 'Backup Jenkins jobs...'
rsync -azPv root@vps01:/var/lib/jenkins/backup $HOME/vps/backup/jenkins

# Backup Nginx setting files from vps01
echo 'Backup Nginx settings...'
rsync -azPv root@vps01:/etc/nginx $HOME/vps/backup/etc

# Backup Artifactory backup files from vps01
echo 'Backup Artifactory files...'
rsync -azPv root@vps01:/var/opt/jfrog/artifactory/backup $HOME/vps/backup/artifactory
