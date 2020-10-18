#!/bin/bash

set -e

# Wait for MySQL server to be up
for i in {30..0}; do
    if mysqladmin ping -h "${DB_HOST}" --silent; then
        break
    fi
    echo 'Waiting for MySQL server...'
    sleep 1
done
if [ "$i" = 0 ]; then
    echo >&2 'MySQL server unavailable!'
    exit 1
fi

# Copy configuration files
cp /var/www/bedita/bedita-app/config/core.php.sample /var/www/bedita/bedita-app/config/core.php
cp /var/www/bedita/bedita-app/config/bedita.cfg.php.sample /var/www/bedita/bedita-app/config/bedita.cfg.php
cp /var/www/bedita/bedita-app/config/database.php.sample /var/www/bedita/bedita-app/config/database.php

# Initialize DB
yes | ./cake.sh bedita initDb

exec "$@"
