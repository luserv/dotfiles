#!/usr/bin/env bash
# Shows a desktop notification listing only workspaces that have windows,
# plus the current workspace (marked with an arrow) even if it is empty.
active=$(wmctrl -d | awk '$2=="*"{print $1}')
windows=$(wmctrl -l)
body=""
for id in $(wmctrl -d | awk '{print $1}'); do
  count=$(awk -v d="$id" '$2==d' <<<"$windows" | wc -l)
  if [ "$id" != "$active" ] && [ "$count" -eq 0 ]; then
    continue
  fi
  mark="  "
  [ "$id" = "$active" ] && mark="▶ "
  body+="$mark$((id + 1))  ($count windows)"$'\n'
done
notify-send -t 3000 -h string:x-canonical-private-synchronous:ws "Workspaces" "${body%$'\n'}"
