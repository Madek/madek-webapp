#!/bin/bash --login

mkdir -p $WORKSPACE/tmp/capybara;
rm -rf $WORKSPACE/log && mkdir -p $WORKSPACE/log
rm -f $WORKSPACE/tmp/*.sql
mkdir -p $WORKSPACE/tmp/html
command -v rvm > /dev/null 2>&1 &&  rvm use 1.9.3
bundle exec rake madek:test:drop_ci_dbs --trace
