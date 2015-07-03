#!/bin/sh
set -ex

# check if your tree still contains the current commit from master
git rev-list --children HEAD | grep -q "$(git rev-parse origin/HEAD)"
