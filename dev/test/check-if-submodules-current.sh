#!/bin/sh
set -ex

# like `check-if-branch-current`, but for all the submodules, recursive.

# make sure all submodules are checked out
# WARNING: test is false-positive without this:
git submodule update --init --recursive

# <git ✨>
# the lowercase variables come from git
# lines explained in order:
# - go to superproject (for this level of recursion)
# - get current commit from remote master
# - get current commit of submodule in current commit from remote master
# - go to the submodule
# - check that the current submodule commit is still contained in tree
git submodule foreach --recursive '\
  cd "${toplevel}" \
  && SUPER_HASH="$(git rev-parse origin/HEAD)" \
  && SUB_HASH=$(git rev-parse ${SUPER_HASH}:${path}) \
  && cd "${path}" \
  && git rev-list --children HEAD | grep -q "^${SUB_HASH}"'
# </git ✨>