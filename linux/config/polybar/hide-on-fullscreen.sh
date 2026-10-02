#!/usr/bin/env bash
exec 9>/tmp/polybar-hide-on-fullscreen.lock
flock -n 9 || exit 0
echo $$ >/tmp/polybar-hide-on-fullscreen.pid
trap 'rm -f /tmp/polybar-hide-on-fullscreen.pid' EXIT

hidden=0

for _ in $(seq 1 50); do
  if polybar-msg cmd show >/dev/null 2>&1; then
    break
  fi
  sleep 0.1
done

screen_res=$(xrandr 2>/dev/null | rtk grep -oP 'current \K[0-9]+ x [0-9]+' | rtk tr -d ' ')
sw="${screen_res%%x*}"
sh="${screen_res##*x}"

while true; do
  wid=
  root_win=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null)
  if [[ "$root_win" =~ (0x[0-9a-fA-F]+) ]]; then
    wid="${BASH_REMATCH[1]}"
  fi

  fs=0
  if [[ -n "$wid" && "$wid" != "0x0" ]]; then
    state=$(xprop -id "$wid" _NET_WM_STATE 2>/dev/null) || state=
    if [[ "$state" == *_NET_WM_STATE_FULLSCREEN* ]]; then
      fs=1
    elif [[ -n "$sw" && -n "$sh" ]]; then
      geom=$(xwininfo -id "$wid" 2>/dev/null)
      ww=$(echo "$geom" | rtk grep -oP 'Width: +\K[0-9]+')
      wh=$(echo "$geom" | rtk grep -oP 'Height: +\K[0-9]+')
      if [[ "$ww" == "$sw" && "$wh" == "$sh" ]]; then
        fs=1
      fi
    fi
  fi

  if (( fs == 1 && hidden == 0 )); then
    polybar-msg cmd hide >/dev/null 2>&1 && hidden=1
  elif (( fs == 0 && hidden == 1 )); then
    polybar-msg cmd show >/dev/null 2>&1 && hidden=0
  fi

  sleep 0.2
done
