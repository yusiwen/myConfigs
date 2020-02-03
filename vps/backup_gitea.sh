#!/bin/sh

cd /var/lib/gitea
/usr/local/bin/gitea/gitea dump
find . -mtime +60 -type f -delete

