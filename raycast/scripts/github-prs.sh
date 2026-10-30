#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title GitHub PRs
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🐙
# @raycast.packageName Work
# @raycast.argument1 { "type": "dropdown", "placeholder": "Which", "data": [{"title": "Mine", "value": "mine"}, {"title": "Review requested", "value": "review"}] }
# @raycast.description Open Lookiero PRs in Brave

case "$1" in
  review) q="is%3Aopen+is%3Apr+review-requested%3A%40me+org%3Alookiero" ;;
  *)      q="is%3Aopen+is%3Apr+author%3A%40me+org%3Alookiero" ;;
esac
open -a "Brave Browser" "https://github.com/pulls?q=$q"
