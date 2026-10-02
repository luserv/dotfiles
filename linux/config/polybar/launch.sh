#!/bin/bash
# Kill any existing polybar instances
if [[ -f /tmp/polybar-hide-on-fullscreen.pid ]]; then
  kill "$(cat /tmp/polybar-hide-on-fullscreen.pid)" 2>/dev/null
  rm -f /tmp/polybar-hide-on-fullscreen.pid
fi
pkill -x polybar 2>/dev/null

# Kill any XFCE panels that might be running
pkill -9 xfce4-panel 2>/dev/null || true
sleep 0.3

# Wait for all polybar processes to terminate
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# Also wait for xfce4-panel to fully terminate
while pgrep -u $UID -x xfce4-panel >/dev/null; do sleep 0.2; done

# Start polybar mainbar at the bottom (now safe since no XFCE panel conflict)
setsid polybar mainbar -c /home/kv/.config/polybar/config.ini >/tmp/polybar.log 2>&1 &
sleep 0.5
/home/kv/.config/polybar/hide-on-fullscreen.sh >/dev/null 2>&1 &
echo "Polybar Big Sur launched, log /tmp/polybar.log"
