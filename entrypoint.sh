#!/bin/sh

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /bin/zsh -c /usr/sbin/sshd -D -e "$@"
