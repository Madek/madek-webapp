#!/bin/sh

 git rev-list --children HEAD | grep -q "$(git rev-parse origin/HEAD)"
