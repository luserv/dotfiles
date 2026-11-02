#!/usr/bin/env bash
# Prints one char per workspace: A = active, O = has windows, E = empty.
active=$(xdotool get_desktop)
total=$(xdotool get_num_desktops)
occupied=" $(wmctrl -l | awk '$2>=0{print $2}' | sort -un | tr '\n' ' ') "
out=""
for ((i = 0; i < total; i++)); do
  if [ "$i" = "$active" ]; then
    out+="A"
  elif [[ "$occupied" == *" $i "* ]]; then
    out+="O"
  else
    out+="E"
  fi
done
printf '%s' "$out"
