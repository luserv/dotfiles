#!/usr/bin/env bash
# Prints audio state for the conky panel.
# Line 1:   <volume percent>|<muted 0|1>
# Line 2..: <app>|<workspace number or ?>|<media title>   (one per playing stream)
# Needs: wpctl, pactl, jq, wmctrl.
set -u

vol_line=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)
vol=$(awk '{printf "%d", $2 * 100 + 0.5}' <<<"$vol_line")
muted=0
[[ "$vol_line" == *MUTED* ]] && muted=1
echo "${vol:-0}|$muted"

# Map window PID -> desktop index (skip sticky windows, desktop -1).
declare -A pid_desk
while read -r _ desk pid _; do
  if [ "$desk" -ge 0 ] 2>/dev/null; then
    pid_desk[$pid]=$desk
  fi
done < <(wmctrl -lp)

# Climb the parent chain until a PID owns a window (audio is often played by a
# child process of the window owner).
find_desk() {
  local pid=$1 depth=0
  while [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null && [ "$depth" -lt 8 ]; do
    if [ -n "${pid_desk[$pid]:-}" ]; then
      echo "${pid_desk[$pid]}"
      return
    fi
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
    depth=$((depth + 1))
  done
}

pactl -f json list sink-inputs 2>/dev/null | jq -r '
  .[]
  | select((.corked // false) == false and (.mute // false) == false)
  | [ (.properties["application.name"] // "?"),
      (.properties["application.process.id"] // ""),
      (.properties["media.name"] // "") ]
  | @tsv' | while IFS=$'\t' read -r app pid title; do
  desk=$(find_desk "$pid")
  ws="?"
  [ -n "$desk" ] && ws=$((desk + 1))
  printf '%s|%s|%s\n' "$app" "$ws" "$title"
done
