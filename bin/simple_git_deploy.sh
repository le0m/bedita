#!/bin/bash

################################################################################
# Simple deploy script of a BEdita4 instance via git
#
# Usage: simple_git_deploy.sh [deploy_user] [app_user] [plugins_list]
#
#  * `deploy_user`: user responsible for git/deploy operations, typically file owner
#  * `app_user`: user launching API actions, typically web server user
#  * `plugins_list`: comma separated list of active plugins to update together with core
#
# Notes:
#  - when no arguments are passed no deploy or app user is set and no plugins are updated
#  - on single argument only `deploy_user` is set, and used as `app_user`` too
#  - `plugins_list`
#       * use relative path inside `plugins/` for names, example: `BEdita/DevTools,MyPlugin`
#       * using `--all-plugins` all plugins found in `plugins/` are updated
#       * on empty `plugins list` no plugins are updated
#
################################################################################

DEPLOY_USER=''
DEPLOY_PREFIX_CMD=''
APP_USER=''
APP_PREFIX_CMD=''

BE4_DIR=$(dirname $(cd $(dirname "$0") && pwd))
if [ $# -eq 0 ]; then
    CURR_USR=`whoami`
    echo "Using current user ($CURR_USR) as deploy and app user"
fi

if [ ! -z "$1" ]; then
    DEPLOY_USER="$1"
    echo "Using $1 as deploy user"
    DEPLOY_PREFIX_CMD="sudo -H -u $DEPLOY_USER "
fi

if [ $# -eq 1 ]; then
    APP_USER="$1"
    echo "Using $1 as app user too"
    APP_PREFIX_CMD="sudo -H -u $APP_USER "
fi

if [ ! -z "$2" ]; then
    APP_USER="$2"
    echo "Using $2 as app user"
    APP_PREFIX_CMD="sudo -H -u $APP_USER "
fi

# 1. create plugins list read from third arg or look in `plugins/``
declare -a PLUGINS_DIR

if [ ! -z "$3" ]; then
    if [ "$3" = "--all-plugins" ]; then
        echo "Look for plugins in plugins/ folder"
        for dir in ./plugins/*/ ; do
            if [[ -d $dir/.git ]]; then
                echo "plugin found: $dir"
                PLUGINS_DIR+=("$dir")
            else
                for subdir in $dir/*/ ; do
            if [[ -d $subdir/.git ]]; then
                        echo "plugin found: $subdir"
                        PLUGINS_DIR+=("$subdir")
                    fi
                done
            fi
        done
    else
        echo "Look for valid plugins in $3"
        IFS=',' read -a PLUGINS_LIST <<< "$3"
        for dir in "${PLUGINS_LIST[@]}"; do
            plug_dir="./plugins/$dir"
            if [[ -d $plug_dir/.git ]]; then
                echo "plugin found: $dir"
                PLUGINS_DIR+=("$plug_dir")
            else
                echo "plugin NOT found: $plug_dir"
            fi
        done
    fi
fi

# 2. update from git
echo "Pull from git on current branch"
echo "$DEPLOY_PREFIX_CMD git pull"
$DEPLOY_PREFIX_CMD git pull

for PLUGIN in ${PLUGINS_DIR[*]};
do
    echo "$DEPLOY_PREFIX_CMD git -C $PLUGIN pull"
    $DEPLOY_PREFIX_CMD git -C $PLUGIN pull
done

# 3. run composer install
echo "$DEPLOY_PREFIX_CMD composer install --no-interaction"
$DEPLOY_PREFIX_CMD composer install --no-interaction

# 4. run migrations
echo "$DEPLOY_PREFIX_CMD bin/cake migrations migrate -p BEdita/Core"
$DEPLOY_PREFIX_CMD bin/cake migrations migrate -p BEdita/Core

echo "$DEPLOY_PREFIX_CMD git checkout -- plugins/BEdita/Core/config/Migrations/schema-dump-default.lock"
$DEPLOY_PREFIX_CMD git checkout -- plugins/BEdita/Core/config/Migrations/schema-dump-default.lock

for PLUGIN in ${PLUGINS_DIR[*]};
do
    echo "$DEPLOY_PREFIX_CMD bin/cake migrations migrate -p ${PLUGIN:10}"
    $DEPLOY_PREFIX_CMD bin/cake migrations migrate -p ${PLUGIN:10}
    echo "$DEPLOY_PREFIX_CMD git -C $PLUGIN checkout -- config/Migrations/schema-dump-default.lock"
    $DEPLOY_PREFIX_CMD git -C $PLUGIN checkout -- config/Migrations/schema-dump-default.lock
done

# 5. clear cache
echo "$APP_PREFIX_CMD bin/cake cache clear_all"
$APP_PREFIX_CMD bin/cake cache clear_all
