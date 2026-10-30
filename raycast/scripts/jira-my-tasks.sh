#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jira My Tasks
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📋
# @raycast.packageName Work
# @raycast.description My open Jira issues in Brave

open -a "Brave Browser" "https://lookiero.atlassian.net/issues/?jql=assignee%20%3D%20currentUser()%20AND%20statusCategory%20!%3D%20Done%20ORDER%20BY%20updated%20DESC"
