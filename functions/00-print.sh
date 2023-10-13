#!/usr/bin/env bash
#
# Copyright (c) 2022 Justin Storfinger [info@jstorfinger.de]
#
# Perform output and logging operations
#

COLRED="\033[1;31m"     # Red color
COLGREEN="\033[1;32m"   # Green color
COLYELLOW="\033[1;33m"  # Yellow color
COLBLUE="\033[1;34m"    # Blue color
COLMAGENTA="\033[1;95m" # Magenta color
COLRESET="\033[0m"      # Color reset

LASTLOG=''
LOGLEVEL="${LOGLEVEL:-20}"
LOGPREFIX="${LOGPREFIX:--}"

##############################################################################
# Print info message to screen
# Globals:
#   COLBLUE, COLYELLOW, COLRED, COLRESET
# Arguments:
#   {1} Status type
#   {2} Message
# Outputs:
#   Status and given message
##############################################################################
function print::msg() {

    case ${1} in
        debug)
            local status="[ ${COLMAGENTA}DEBUG${COLRESET}  ]"
            local loglevel=10;;
        info)
            local status="[  ${COLBLUE}INFO${COLRESET}  ]"
            local loglevel=20;;
        warn)
            local status="[  ${COLYELLOW}WARN${COLRESET}  ]"
            local loglevel=30;;
        failed)
            local status="[ ${COLRED}FAILED${COLRESET} ]"
            local loglevel=40;;
        *) ;;
    esac

    if [[ ${LOGLEVEL} -le ${loglevel} ]]; then
        [ -t 0 ] && \
            printf "${status} %s \n" "${2}" 1>&2 || \
            printf "$(date '+%Y-%m-%d %H:%M:%S') ::: %s ${status} \n" "${2}" 1>&2
    fi
    if [[ 20 -le ${loglevel} ]] || [[ ${LOGLEVEL} -le 10 ]]; then
        print::write_log "${1}" "${2}"
    fi

}

##############################################################################
# Print info message to screen and wait for status
# Arguments:
#   {1} Message
# Outputs:
#   Waiting status
##############################################################################
function print::msg_waitstat() {
    local loglevel=20
    if [[ ${LOGLEVEL} -le ${loglevel} ]]; then
        [ -t 0 ] && \
            printf "[ ...... ] %s \r" "${1}"  1>&2 || \
            printf "$(date '+%Y-%m-%d %H:%M:%S') ::: %s " "${1}" 1>&2
    fi
    LASTLOG="${1}"
    print::write_log "await" "${1}"
}

##############################################################################
# Print info status by overwriting wait status
# Globals:
#   COLBLUE, COLGREEN, COLYELLOW, COLRED, COLRESET
# Arguments:
#   {1} Status type
# Outputs:
#   Status after cmd runtime finished
##############################################################################
function print::stat() {
    local loglevel=20

    case ${1} in
        info)
            local status="[  ${COLBLUE}INFO${COLRESET}  ]"
            local level=20 ;;
        passed)
            local status="[ ${COLGREEN}PASSED${COLRESET} ]"
            local level=20 ;;
        warn)
            local status="[  ${COLYELLOW}WARN${COLRESET}  ]"
            local level=30 ;;
        failed)
            local status="[ ${COLRED}FAILED${COLRESET} ]"
            local level=40  ;;
        *) ;;
    esac

    if [[ ${LOGLEVEL} -le ${loglevel} ]]; then
        printf "${status}\n" 1>&2
    elif [[ ${LOGLEVEL} -le ${level} ]]; then
        print::msg "${1}" "${LASTLOG}"
    fi
}

##############################################################################
# Write log messages to file
# Globals:
#   LOGFILE
# Arguments:
#   {1} Message
##############################################################################
function print::write_log() {
    printf "$(date '+%Y-%m-%d %H:%M:%S') : %-6s : %s : ${2} \n" "${1^^}" "${LOGPREFIX:--}" >>"${LOGFILE}"
}

##############################################################################
# Write command to file
# Globals:
#   LOGFILE
# Arguments:
#   {1} Command
##############################################################################
function print::cmd_log() {
    print::write_log "cmd" "${1}"
}

##############################################################################
# Print horizontal line
##############################################################################
function print::line() {
    local loglevel=20

    if [[ ${LOGLEVEL} -le ${loglevel} ]]; then
        echo $(printf "%0.s-" {1..120}) 1>&2
    fi
}

##############################################################################
# Print a double line (=)
##############################################################################
function print::doubleline() {
    local loglevel=20

    if [[ ${LOGLEVEL} -le ${loglevel} ]]; then
        echo $(printf "%0.s=" {1..120}) 1>&2
    fi
}