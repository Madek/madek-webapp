#!/bin/bash
set -exu

# Example: 
# ./dev/utilities/image-diff.sh ~/Desktop/styleguide-ref ~/Downloads/styleguide-ref "Components/thumb_catalog.png"

REFS="$1"
NEW="$2"
FILE="$3"

compare \
  "$REFS"/"$FILE" \
  "$NEW"/"$FILE" \
  "$NEW"/"$(basename "$FILE" '.png').diff.png"
