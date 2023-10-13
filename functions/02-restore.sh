#!/usr/bin/env bash
#
# Copyright (c) 2022 Justin Storfinger [info@jstorfinger.de]
#

##################################################
# Restore gitlab backup
# Globals:
#   BACKUPDIR
#   SECRETDIR
#   LOGFILE
# Arguments:
#   backupfile
#   BACKUP
#   backupstring
#   GITLAB_ASSUME_YES
#   secretsbackupfile
##################################################

function gitlab::restore() {
    echo ''
    ls -1 ${BACKUPDIR}
    
    echo -n 'Please select the backup: '

    read -r backupfile

    # Check if backup file exists
    if [ ! -f "${BACKUPDIR}/${backupfile}" ]; then
        echo ''
        print::msg 'failed' 'File does not exist, please correct your input!'
        exit 1
    else
        echo ''
        print::msg 'info' "Continuing with your backup file ${BACKUPDIR}/${backupfile} ..."
        echo ''
    fi

    ls -1 ${SECRETDIR}

    echo -n 'Please select the configuration backup: '

    read -r secretsbackupfile

    # Check if backup file exists
    if [ ! -f "${SECRETDIR}/${secretsbackupfile}" ]; then
        echo ''
        print::msg 'failed' 'File does not exist, please correct your input!'
        exit 1
    else
        echo ""
        print::msg 'info' "Continuing with your configuration backup file ${SECRETDIR}/${secretsbackupfile} ..."
        echo ""
    fi

    # Modify file name input
    backupstring=${backupfile: : -18}

    # Stop services connected to the database

    print::msg_waitstat 'Stop puma service ... ( gitlab-ctl stop puma )'

    if [ $? -eq 0 ]; then
        gitlab-ctl stop puma 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi

    print::msg_waitstat 'Stop sidekiq service ... ( gitlab-ctl stop sidekiq )'

    if [ $? -eq 0 ]; then
        gitlab-ctl stop sidekiq 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi

    # Restore gitlab

    print::msg_waitstat "Restoring GitLab backup ... ( GITLAB_ASSUME_YES=1 gitlab-backup restore BACKUP=${backupstring} )"

    if [ $? -eq 0 ]; then
        GITLAB_ASSUME_YES=1 gitlab-backup restore BACKUP=${backupstring} 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi

    tar -xf ${SECRETDIR}/${secretsbackupfile} -C / 1>>${LOGFILE}

    # Reconfigure gitlab

    print::msg_waitstat 'Reconfiguring GitLab ... ( gitlab-ctl reconfigure )'

    if [ $? -eq 0 ]; then
        gitlab-ctl reconfigure 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi

    print::msg_waitstat 'Restarting GitLab ... ( gitlab-ctl restart )'

    if [ $? -eq 0 ]; then
        gitlab-ctl restart 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi
}