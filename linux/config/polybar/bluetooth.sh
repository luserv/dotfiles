#!/bin/bash

# Bluetooth status script for Polybar
# Shows Bluetooth status and toggles power on click

# Bluetooth status icons
ICON_CONNECTED="󰂱"
ICON_DISCONNECTED="󰂲"
ICON_OFF="󰂲"

# Check if bluetooth is available
if ! command -v bluetoothctl &>/dev/null; then
    echo "$ICON_OFF"
    exit 0
fi

# Get bluetooth power status
POWERED=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

if [[ "$POWERED" == "yes" ]]; then
    # Check for connected devices
    CONNECTED=$(bluetoothctl devices | grep -c "Connected: yes")
    if [[ "$CONNECTED" -gt 0 ]]; then
        echo "$ICON_CONNECTED"
    else
        echo "$ICON_DISCONNECTED"
    fi
else
    echo "$ICON_OFF"
fi