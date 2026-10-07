#!/usr/bin/env bash
# Serve test-videojs.html with Python's built-in static server.
# Media is loaded from the public Mux CDN (no local video files needed).
#
# Usage:
#   ./serve-test-videojs.sh
#   ./serve-test-videojs.sh 8765

set -euo pipefail

PORT="${1:-8000}"
DIR="$(cd "$(dirname "$0")" && pwd)"
URL="http://127.0.0.1:${PORT}/test-videojs.html"

# Prefer a real interpreter over asdf shims when the pinned version is missing.
if [[ -x /usr/bin/python3 ]]; then
  PYTHON=/usr/bin/python3
elif command -v python3 >/dev/null 2>&1; then
  PYTHON="$(command -v python3)"
else
  echo "No python3 found. Install one, or run: asdf install python 3.11.1" >&2
  exit 1
fi

cd "$DIR"
echo "Serving ${DIR} with ${PYTHON}"
echo "Open ${URL}"
echo "Demo media: public Big Buck Bunny / SoundHelix URLs (needs internet)"
echo "Ctrl+C to stop"
exec "$PYTHON" -m http.server "$PORT" --bind 127.0.0.1
