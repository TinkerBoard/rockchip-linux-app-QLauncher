#!/bin/bash

set -xe

# Support Arbitrary User IDs for ssh
# https://docs.okd.io/latest/creating_images/guidelines.html
#if ! whoami &> /dev/null; then
#    if [ -w /etc/passwd ]; then
#        echo "${USER_NAME:-builder}:x:$(id -u):$(id -g):${USER_NAME:-builder} user:${HOME}:/usr/sbin/nologin" >> /etc/passwd
#        export USER=$(whoami)
#    fi
#fi

exec "$@"
