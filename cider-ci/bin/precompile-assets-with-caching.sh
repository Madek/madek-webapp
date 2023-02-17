#!/usr/bin/env bash
set -eux

DIGEST=`git ls-tree HEAD --\
  app/assets node_modules package.json \
  config Gemfile.lock \
  cider-ci cider-ci.yml \
| openssl dgst -sha1 | cut -d ' ' -f 2`

ASSETS_CACHE_DIR="/tmp/assets_${DIGEST}"
NODE_MODULES_CACHE_DIR="/tmp/node_modules_${DIGEST}"

if [ -d "$ASSETS_CACHE_DIR" ]; then
  echo "assets cache exists, just linking... ${ASSETS_CACHE_DIR}"
  rm -rf node_modules
  rm -rf public/assets
else
  bin/precompile-assets
  mv node_modules "${NODE_MODULES_CACHE_DIR}"
  mv public/assets "${ASSETS_CACHE_DIR}"
fi
ln -s "$NODE_MODULES_CACHE_DIR" node_modules
ln -s "$ASSETS_CACHE_DIR" public/assets
