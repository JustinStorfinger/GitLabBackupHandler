#!/usr/bin/env bash
#
# Copyright (c) 2022 Justin Storfinger [info@jstorfinger.de]
#

##################################################
# Create gitlab backup aswell configuration backup
# Globals:
#   BACKUPDIR
#   SECRETDIR
#   LOGFILE
# Arguments:
#   None
##################################################

function gitlab::backup() {
    echo ''
    print::msg_waitstat 'Create gitlab backup ... ( gitlab-backup create )'

    # Create backup
    if [ $? -eq 0 ]; then
        gitlab-backup create 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi

    print::msg_waitstat 'Create configuration backup ... ( gitlab-ctl backup-etc )'

    # Create backup of configuration files
    if [ $? -eq 0 ]; then
        gitlab-ctl backup-etc 2>&1 1>>${LOGFILE} || {
            print::stat 'failed'
            exit 1
        }
        print::stat 'passed'
    fi

    print::msg 'info' 'All tasks done! Exiting...'
    echo ''
}