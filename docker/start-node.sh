#!/bin/sh
set -eu
mkdir -p /run/sshd
ssh-keygen -A
/usr/sbin/sshd
exec nginx -g 'daemon off;'
