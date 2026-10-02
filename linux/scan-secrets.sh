#!/usr/bin/env bash
# Scan files for likely secrets before committing them.
# Usage: linux/scan-secrets.sh <file-or-dir>...   (default: linux/)
# Exit code: 0 = no hits, 1 = hits found (review each one), 2 = oversized file.
set -uo pipefail

MAX_BYTES=$((200 * 1024))
PATTERN='token|secret|passw(or)?d|api[_-]?key|bearer|authorization|private key|BEGIN .* PRIVATE|ghp_|github_pat_|sk-[A-Za-z0-9]|AKIA|oauth|credential|cookie|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|[a-z]+://[^/ ]*:[^/ ]*@'

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
targets=("$@")
[ ${#targets[@]} -eq 0 ] && targets=("$root/linux")

status=0
while IFS= read -r -d '' f; do
  [ "$f" = "${BASH_SOURCE[0]}" ] && continue
  case "$f" in */scan-secrets.sh) continue ;; esac
  size=$(stat -c %s "$f")
  if [ "$size" -gt "$MAX_BYTES" ]; then
    echo "TAMANO: $f ($size bytes > $MAX_BYTES)"
    status=2
    continue
  fi
  if rg -n -i --no-heading -e "$PATTERN" -- "$f"; then
    [ "$status" -eq 0 ] && status=1
  fi
done < <(find "${targets[@]}" -type f -print0)

exit "$status"
