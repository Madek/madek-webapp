#!/usr/bin/env bash
set -e
set -u
NPM_VERSIONS_DIGEST=`git hash-object 'package.json'`
NPM_CACHE_DIR="/tmp/MADEK_NPM-CACHE_${NPM_VERSIONS_DIGEST}/node_modules"

if [ -d "$NPM_CACHE_DIR" ]; then
  echo "NPM module cache exists, just linking..."
else
  echo "NPM modules are yet missing; setting up ..."
  TMP_DIR="${NPM_CACHE_DIR}_${CIDER_CI_TRIAL_ID}"
  mkdir -p "$TMP_DIR"
  ln -s "$TMP_DIR" "node_modules"
  npm install
  rm node_modules
  mv "$TMP_DIR" "$NPM_CACHE_DIR"
fi
ln -s "$NPM_CACHE_DIR" node_modules
