#!/bin/sh

# Copyright (c) 2021 Jesse N. <jesse@keplerdev.com>
# This work is licensed under the terms of the MIT license. For a copy, see <https://opensource.org/licenses/MIT>.

ENTRYPOINT_COMMAND=$1
shift
ENTRYPOINT_PARAMS=$@

# set user group and home
set-user-group-home

# chown path
chown-path

# exec ENTRYPOINT_COMMAND as user
exec su-exec $EUSER $ENTRYPOINT_COMMAND $ENTRYPOINT_PARAMS