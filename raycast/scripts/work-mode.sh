#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Work Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 💼
# @raycast.packageName Modes
# @raycast.description Open work apps, close personal ones, enable the "Trabajo" Focus shortcut if it exists

for app in "Warp" "Slack" "Brave Browser" "Spotify"; do open -ga "$app"; done
osascript -e 'quit app "WhatsApp"' 2>/dev/null || true
shortcuts list | grep -qx "Trabajo" && shortcuts run "Trabajo"
echo "Work mode on"
