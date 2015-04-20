#!/bin/sh
set -e

# CONFIG:
BUMP="major" # we are refactoring here…

# how to use node scripts w/o a package.json… -.-
MYDIR="${PWD}/$(dirname $0)"

cd "${MYDIR}/../lib/git-describe-semver"
npm install >/dev/null

cd "${MYDIR}"
node "${MYDIR}/../lib/git-describe-semver/git-describe-semver.js" \
  --describe="$(git describe --tag --always --long)" \
  --bump=${BUMP} \
  --json # give answer as JSON object…
