#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jira Ticket
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🎫
# @raycast.packageName Work
# @raycast.argument1 { "type": "text", "placeholder": "45698 or LK-45698" }
# @raycast.description Open a Lookiero Jira ticket in Brave

key="$1"
[[ "$key" =~ ^[0-9]+$ ]] && key="LK-$key"
key=$(printf %s "$key" | tr "[:lower:]" "[:upper:]")
open -a "Brave Browser" "https://lookiero.atlassian.net/browse/$key"
