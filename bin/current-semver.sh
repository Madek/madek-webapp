#!/bin/sh
set -e
# This is just a shell script so it can be run standalone, also because ruby.

# config: what kind of changes were made in this branch?
CHANGE="breaking" # true while refactoring…

# TODO: enable when ci has current npm
# npm run -s git-semver -- \
  # --json --change=${CHANGE} $(git describe --tag --always --long)

# TMP:
node ./node_modules/git-describe-semver/git-describe-semver.js \
  --json --change=${CHANGE} $(git describe --tag --always --long)
