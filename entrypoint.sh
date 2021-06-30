#!/bin/sh

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec "${SSH_USER_SHELL}" -c /usr/sbin/sshd -D -e "$@"
