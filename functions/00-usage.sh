#!/usr/bin/env bash
#
# Copyright (c) 2022 Justin Storfinger [info@jstorfinger.de]
#
# Shows script usage
#

function print::usage() {
    echo ''
    echo "Usage: $(basename ${0}) {backup|restore}"
    echo ''
    echo 'Commands:'
    echo 'backup                Run gitlab backup and create backup of configuration files'
    echo 'restore               Restore gitlab backup as well configuration backup (You need to have the same version as the selected backup)'
    echo ''
}