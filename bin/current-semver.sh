#!/bin/sh
set -e
# This is just a shell script so it can be run standalone,
# NOT USED in the ruby application.

{ ./node_modules/js-yaml/bin/js-yaml.js '.release.yml' \
    | ./node_modules/json/lib/json.js 'semver' \
  && echo "{\"build\":[\"g$(git log -n1 --format="%h")\"]}" ;
} \
  | ./node_modules/json/lib/json.js --deep-merge
