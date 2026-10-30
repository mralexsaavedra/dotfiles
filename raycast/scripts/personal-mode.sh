#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Personal Mode
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🏠
# @raycast.packageName Modes
# @raycast.description Close work apps, open personal ones, run the "Personal" shortcut if it exists

for app in "Slack" "Figma"; do osascript -e "quit app \"$app\"" 2>/dev/null || true; done
for app in "WhatsApp" "Safari"; do open -ga "$app"; done
shortcuts list | grep -qx "Personal" && shortcuts run "Personal"
echo "Personal mode on"
