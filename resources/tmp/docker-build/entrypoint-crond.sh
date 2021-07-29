#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

CROND_PARAMS=( $@ )

if [ -z "${CROND_CRONTAB}" ]; then
   echo "missing environment variable: CROND_CRONTAB"
   exit 1
fi

# set user group and home
set-user-group-home

# chown path
chown-path

# configure and exec cron deamon
crontab -u "${EUSER}" "${CROND_CRONTAB}"

crond "${CROND_PARAMS[@]}"