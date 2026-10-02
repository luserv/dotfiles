#!/bin/bash
# Theme toggle script for Polybar
# Usage: theme-toggle.sh          → print current mode (polybar exec)
#        theme-toggle.sh toggle   → toggle theme and restart polybar

THEMES_DIR="$HOME/.config/gtk-3.0"
SETTINGS_FILE="$THEMES_DIR/settings.ini"

# Current state
CURRENT_DARK=$(grep '^gtk-application-prefer-dark-theme=' "$SETTINGS_FILE" 2>/dev/null | cut -d= -f2)

if [[ -z "$CURRENT_DARK" ]]; then
    CURRENT_DARK="true"
fi

if [[ "$1" != "toggle" ]]; then
    # Just report current mode (polybar exec / interval refresh)
    if [[ "$CURRENT_DARK" == "true" ]]; then
        echo "dark"
    else
        echo "light"
    fi
    exit 0
fi

# --- Toggle mode (click-left) ---

if [[ "$CURRENT_DARK" == "true" ]]; then
    NEW_DARK="false"
    NEW_THEME="Breeze"
    NEW_ICONS="breeze"
    TARGET_MODE="light"
else
    NEW_DARK="true"
    NEW_THEME="Breeze-Dark"
    NEW_ICONS="breeze-dark"
    TARGET_MODE="dark"
fi

sed -i "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$NEW_DARK/" "$SETTINGS_FILE"
sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$NEW_THEME/" "$SETTINGS_FILE"
sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$NEW_ICONS/" "$SETTINGS_FILE"

if command -v xrdb >/dev/null 2>&1; then
    xrdb -merge - <<EOF &>/dev/null
*gtk-theme-name: $NEW_THEME
*gtk-icon-theme-name: $NEW_ICONS
*gtk-application-prefer-dark-theme: $NEW_DARK
EOF
fi

if [[ "$TARGET_MODE" == "dark" ]]; then
    ICON="󰎫"
    MESSAGE="Theme: Dark"
else
    ICON="󰎪"
    MESSAGE="Theme: Light"
fi

if command -v dunstify >/dev/null 2>&1; then
    dunstify -u low -i "$ICON" "$MESSAGE"
elif command -v notify-send >/dev/null 2>&1; then
    notify-send -i "$ICON" "$MESSAGE"
fi

pkill -x polybar 2>/dev/null
sleep 1
setsid polybar mainbar -c /home/kv/.config/polybar/config.ini >/tmp/polybar.log 2>&1 &

echo "$TARGET_MODE"
