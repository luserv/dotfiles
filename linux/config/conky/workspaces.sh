#!/usr/bin/env bash
# Prints workspace indicator using conky color markup.
# active = accent, occupied = default, empty = dim.
active=$(wmctrl -d | awk '$2=="*"{print $1}')
occupied=" $(wmctrl -l | awk '$2>=0{print $2}' | sort -un | tr '\n' ' ') "
out=""
for id in $(wmctrl -d | awk '{print $1}'); do
  n=$((id + 1))
  if [ "$id" = "$active" ]; then
    out+="\${color1}[$n]\${color} "
  elif [[ "$occupied" == *" $id "* ]]; then
    out+="$n "
  else
    out+="\${color 555555}$n\${color} "
  fi
done
printf '%s' "$out"
