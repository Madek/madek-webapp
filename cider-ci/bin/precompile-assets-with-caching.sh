#!/usr/bin/env bash
set -eux

DIGEST=`git ls-tree HEAD --\
  app/assets node_modules package.json \
  config Gemfile.lock \
  cider-ci cider-ci.yml \
| openssl dgst -sha1 | cut -d ' ' -f 2`

ASSETS_CACHE_DIR="/tmp/assets_${DIGEST}"

if [ -d "$ASSETS_CACHE_DIR" ]; then
  echo "assets cache exists, just linking... ${ASSETS_CACHE_DIR}"
  # delete checked in directory or the symlink will fail!
  rm -rf public/assets
else
  bin/precompile-assets
  mv public/assets "${ASSETS_CACHE_DIR}"
fi
ln -s "$ASSETS_CACHE_DIR" public/assets
