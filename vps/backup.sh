#!/bin/sh

# Backup MySql database backup files from vps01
rsync -azPv root@vps01:/var/vmail/backup/mysql $HOME/vps/backup/mysql

# Backup let's encrypt certificates from vps01
rsync -azPv root@vps01:/etc/letsencrypt $HOME/vps/backup/etc/letsencrypt

# Backup Jenkins backup files from vps01
rsync -azPv root@vps01:/var/lib/jenkins/backup $HOME/vps/backup/jenkins

