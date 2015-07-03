#!/bin/sh

# - for each submodule
# - get submodule hash from last commit in super project
# - check if that old hash is a child of the new hash
git submodule foreach '\
  cd "$toplevel" && PREV_COMMIT=$(git rev-parse HEAD^1:${path}) && cd "$path" \
  && git rev-list --children HEAD | grep -q "^${PREV_COMMIT}"'
