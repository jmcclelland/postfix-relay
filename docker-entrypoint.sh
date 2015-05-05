#!/bin/bash
set -e

if [ "$1" = 'postfix' ]; then
  exec /usr/lib/postfix/master -d
fi

exec "$@"
