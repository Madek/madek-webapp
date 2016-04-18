#!/usr/bin/env bash
set -eux

DIGEST=`git ls-tree HEAD --\
  app/assets node_modules package.json \
  config Gemfile.lock cider-ci/bin/precompile-assets-with-caching.sh \
| openssl dgst -sha1 | cut -d ' ' -f 2`

ASSETS_CACHE_DIR="/tmp/assets_${DIGEST}"

if [ -d "$ASSETS_CACHE_DIR" ]; then
  echo "assets cache exists, just linking... ${ASSETS_CACHE_DIR}"
else
  bin/precompile-assets
  mv public/assets "${ASSETS_CACHE_DIR}"
fi
ln -s "$ASSETS_CACHE_DIR" public/assets
