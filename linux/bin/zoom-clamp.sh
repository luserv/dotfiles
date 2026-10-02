#!/usr/bin/env bash
# Keeps Zoom windows (meeting + docked chat/participants panel) from growing
# wider than the monitor, which would push the panel off-screen.
# Root cause: on Linux, Zoom docks the chat/participants panel by widening the
# meeting window past the screen edge instead of shrinking the video area.
# Dependencies: wmctrl, xdotool (already installed).

MAXW=$(xdotool getdisplaygeometry 2>/dev/null | awk '{print $1}')
[ -n "$MAXW" ] || MAXW=1920

while :; do
  while read -r wid _ cls _; do
    [ "$cls" = "zoom.zoom" ] || continue
    eval "$(xdotool getwindowgeometry --shell "$wid" 2>/dev/null)"
    if [ -n "$WIDTH" ] && [ "$WIDTH" -gt "$MAXW" ]; then
      wmctrl -i -r "$wid" -e 0,0,"${Y:-0}","$MAXW","${HEIGHT:-1054}"
    fi
  done < <(wmctrl -lx 2>/dev/null)
  sleep 1
done
