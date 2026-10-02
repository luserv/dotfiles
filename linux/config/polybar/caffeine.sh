#!/bin/bash

get_status() {
    if xset q 2>/dev/null | grep -q "DPMS is Disabled"; then
        echo "on"
    else
        echo "off"
    fi
}

print_status() {
    local status=$(get_status)
    if [ "$status" = "on" ]; then
        echo "%{F#82FB9C}󰅶%{F-}"
    else
        echo "󰾪"
    fi
}

toggle() {
    local status=$(get_status)
    if [ "$status" = "on" ]; then
        xset +dpms
        xset s on
    else
        xset -dpms
        xset s off
    fi
}

case "$1" in
    toggle)
        toggle
        ;;
    *)
        print_status
        ;;
esac
