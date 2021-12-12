#!/usr/bin/env bash

# Author:   Siwen Yu(yusiwen@gmail.com) 
# Date:     21/03/2017
# Purpose:  Backup specified postgresql databases with command 'pg_dump'.
# License:  This shell script is released under GPL v2.

###########################
# REQUIREMENTS
###########################
#
#   * Required commands:
#       + pg_dump
#       + du
#       + bzip2     # If bzip2 is not available, change 'CMD_COMPRESS'
#                   # to use 'gzip'.
#

###########################
# USAGE
###########################
#
#   * It stores all backup copies in directory '/var/lib/postgresql/backup' by default,
#     You can change it in variable $BACKUP_ROOTDIR below.
#
#   * Set correct values for below variables:
#
#       BACKUP_ROOTDIR
#       PG_ROOT_USER
#       DATABASES
#       DB_CHARACTER_SET
#
#   * Add crontab job for root user (or whatever user you want):
#
#       # crontab -e -u root
#       1   4   *   *   *   bash /path/to/backup_pg.sh
#
#   * Make sure 'crond' service is running, and will start automatically when
#     system startup:
#
#       # ---- On RHEL/CentOS ----
#       # chkconfig --level 345 crond on
#       # /etc/init.d/crond status
#
#       # ---- On Debian/Ubuntu ----
#       # update-rc.d cron defaults
#       # /etc/init.d/cron status
#

#########################################################
# Modify below variables to fit your need ----
#########################################################
# Keep backup for how many days. Default is 90 days.
KEEP_DAYS='90'

# Where to store backup copies.
export BACKUP_ROOTDIR="/var/lib/postgresql/backup"

# PostgreSQL docker container name
export PG_CONTAINER_NAME='postgres'
# PostgreSQL username. Root user is required to dump all databases.
export PG_ROOT_USER='postgres'

# Databases we should backup.
# Multiple databases MUST be seperated by SPACE.
export DATABASES='postgres keycloak sonardb'

# Database character set for ALL databases.
# Note: Currently, it doesn't support to specify character set for each databases.
export DB_CHARACTER_SET="utf8"

#########################################################
# You do *NOT* need to modify below lines.
#########################################################
export PATH='/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin'

# Commands.
export CMD_DATE='/bin/date'
export CMD_DU='du -sh'
export CMD_COMPRESS='bzip2 -9'
export COMPRESS_SUFFIX='bz2'
export CMD_PG="docker exec ${PG_CONTAINER_NAME} psql -U ${PG_ROOT_USER}"
export CMD_PGDUMP="docker exec ${PG_CONTAINER_NAME} pg_dump -U ${PG_ROOT_USER} -F t"

# Date.
export YEAR="$(${CMD_DATE} +%Y)"
export MONTH="$(${CMD_DATE} +%m)"
export DAY="$(${CMD_DATE} +%d)"
export TIME="$(${CMD_DATE} +%H-%M-%S)"
export TIMESTAMP="${YEAR}-${MONTH}-${DAY}-${TIME}"

# Pre-defined backup status
export BACKUP_SUCCESS='YES'

# Define, check, create directories.
export BACKUP_DIR="${BACKUP_ROOTDIR}/${YEAR}/${MONTH}/${DAY}"

# Find the old backup which should be removed.
export REMOVE_OLD_BACKUP='NO'
if which python &>/dev/null; then
    export REMOVE_OLD_BACKUP='YES'
    py_cmd="import time; import datetime; t=time.localtime(); print datetime.date(t.tm_year, t.tm_mon, t.tm_mday) - datetime.timedelta(days=${KEEP_DAYS})"
    shift_date=$(python -c "${py_cmd}")
    shift_year="$(echo ${shift_date} | awk -F'-' '{print $1}')"
    shift_month="$(echo ${shift_date} | awk -F'-' '{print $2}')"
    shift_day="$(echo ${shift_date} | awk -F'-' '{print $3}')"
    export REMOVED_BACKUP_DIR="${BACKUP_ROOTDIR}/${shift_year}/${shift_month}/${shift_day}"
fi

# Log file
export LOGFILE="${BACKUP_DIR}/${TIMESTAMP}.log"

# Verify database connection.
${CMD_PG} -c '\list' &>/dev/null
if [ X"$?" != X"0" ]; then
    echo "[ERROR] PostgreSQL username or password is incorrect in file ${0}." 1>&2
    echo "Please fix them first." 1>&2

    exit 255
fi

# Check and create directories.
[ ! -d ${BACKUP_DIR} ] && mkdir -p ${BACKUP_DIR} 2>/dev/null
chown root ${BACKUP_DIR}
chmod 0400 ${BACKUP_DIR}

# Initialize log file.
echo "* Starting backup: ${TIMESTAMP}." >${LOGFILE}
echo "* Backup directory: ${BACKUP_DIR}." >>${LOGFILE}
chmod 0400 ${LOGFILE}

# Backup.
echo "* Backing up databases: ${DATABASES}." >> ${LOGFILE}
for db in ${DATABASES}; do
    output_tar="${BACKUP_DIR}/${db}-${TIMESTAMP}.tar"

    # Check database existence
    ${CMD_PG} -c "\c ${db}" &>/dev/null

    if [ X"$?" == X'0' ]; then
        # Dump
        ${CMD_PGDUMP} ${db} > ${output_tar}
        chmod 0400 ${output_tar}

        if [ X"$?" == X'0' ]; then
            # Get original SQL file size
            original_size="$(${CMD_DU} ${output_tar} | awk '{print $1}')"

            # Compress
            ${CMD_COMPRESS} ${output_tar} >>${LOGFILE}
            chmod 0400 ${output_tar}.*

            if [ X"$?" == X'0' ]; then
                rm -f ${output_tar} >> ${LOGFILE}
            fi
        else
            # backup failed
            export BACKUP_SUCCESS='NO'
        fi
    fi
done

# Append file size of backup files.
echo -e "* File size:\n----" >>${LOGFILE}
cd ${BACKUP_DIR} && \
${CMD_DU} *${TIMESTAMP}*tar* >>${LOGFILE}
echo "----" >>${LOGFILE}

echo "* Backup completed (Success? ${BACKUP_SUCCESS})." >>${LOGFILE}

if [ X"${BACKUP_SUCCESS}" == X'YES' ]; then
    echo "==> Backup completed successfully."
else
    echo -e "==> Backup completed with !!!ERRORS!!!.\n" 1>&2
fi

if [ X"${REMOVE_OLD_BACKUP}" == X'YES' ] && [ -d ${REMOVED_BACKUP_DIR} ]; then
    echo -e "* Old backup found. Deleting: ${REMOVED_BACKUP_DIR}." >>${LOGFILE}
    rm -rf ${REMOVED_BACKUP_DIR} >> ${LOGFILE} 2>&1
fi

echo "==> Detailed log (${LOGFILE}):"
echo "========================="
cat "${LOGFILE}"
