#!/usr/bin/env bash

ROOT_PATH="$(cd "$(dirname "$0")/../" && pwd -P)"

FILE_ENV="$ROOT_PATH/.env"
UPDATE_ENV="0"

VERBOSE="0"
DRY_RUN="0"

function msg() {
    echo "$(date):" $1
}

function run() {
    local CMD=${1//\$/\\\$}
    if [ "$VERBOSE" != "0" ]; then
        msg "$CMD"
    fi
    if [ "$DRY_RUN" = "0" ]; then
        eval $CMD
    fi
}

function docker_run() {
    local CMD="sh"
    local ARGS="-c \"${1//\"/\\\"}\""
    if [ $# -gt 1 ]; then
        CMD=$1
        ARGS=$2
    fi
    run "docker-compose exec php $CMD $ARGS"
}

function error() {
    msg "ERROR: $1"
    exit 1
}

function read_env() {
    if [ -f "$FILE_ENV" ]; then
        run "source $FILE_ENV"
    else
        UPDATE_ENV="1"
    fi
}

function read_params() {
    if [ $# -gt 0 ]; then
        UPDATE_ENV="1"
        while true; do
            if [ "$1" = "" ]; then
                break
            fi

            VAR=$(echo "${1#*--}" | tr '-' '_' | tr a-z A-Z)
            export $VAR="$2"
            shift 2
        done
    fi
}

function get_var() {
    local VAR_NAME=$1
    local DEFAULT_VALUE=$2
    local SECURE=$3
    if [ "${!VAR_NAME}" = "" ]; then
        UPDATE_ENV="1"

        local MESSAGE=$VAR_NAME
        if [ "$DEFAULT_VALUE" != "" ]; then
            MESSAGE="$MESSAGE($DEFAULT_VALUE)"
        fi

        local READ_ARGS="-"
        if [ "$SECURE" != "" ]; then
            READ_ARGS="${READ_ARGS}s"
        fi

        read ${READ_ARGS}p "$MESSAGE: " USER_VALUE
        if [ "$SECURE" != "" ]; then
            echo
        fi

        if [ "$USER_VALUE" != "" ]; then
            VALUE="$USER_VALUE"
        else
            VALUE="$DEFAULT_VALUE"
        fi

        if [ "$VALUE" = "" ]; then
            error "$VAR_NAME is not specified"
        fi

        export -n "$VAR_NAME=$VALUE"
    fi
}

function save_env() {
    if [ "$UPDATE_ENV" = "1" ]; then
        run "rm -f $FILE_ENV"
        for VAR in "${!MAGENTO_@}"; do
            save_var "$VAR" "${!VAR}"
        done
    fi
}

function save_var() {
    local VAR=$1
    local VAL=$2
    local LINE="${VAR}="
    local RE="[[:space:]]+"
    if [[ "$VAL" =~ $RE ]]; then
        LINE="${LINE}'"
    fi
    LINE="${LINE}${VAL}"
    if [[ "$VAL" =~ $RE ]]; then
        LINE="${LINE}'"
    fi
    run "echo \"$LINE\" >> $FILE_ENV"
}

function ver() {
    printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' ')
}

function fixcreds() {
    docker_run "chown www-data:www-data -R generated/"
    docker_run "chown www-data:www-data -R pub/media/"
    docker_run "chown www-data:www-data -R pub/static/"
    docker_run "chown www-data:www-data -R var/"
}
