#!/bin/sh
LOGFILE=$1
shift
/bin/sh -v "$@" 2>&1 | install -D /dev/stdin /var/log/artifacts/$LOGFILE
