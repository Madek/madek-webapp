#!/bin/sh
set -ex

REMOTE_HASH=$(ssh root@test.madek.zhdk.ch 'cd /home/madek/madek_app && git log -n1 --format="%h"')
DUMPFILE="db/backups/test.zhdk-data_${REMOTE_HASH}.pgbin"

mkdir -p "db/backups"
rsync -LPh root@test.madek.zhdk.ch:/home/madek/madek_app/db/data.pgbin "$DUMPFILE"
bundle exec rake db:pg:terminate_connections db:drop || true # ignore error if not exists yet
bundle exec rake db:create db:migrate db:pg:truncate_tables
time bundle exec rake db:pg:data:restore FILE="$DUMPFILE"