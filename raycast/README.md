# Raycast Configuration Backup
This directory is reserved for your manual Raycast configuration exports.

## How to backup
1. Open Raycast Settings (`Cmd + ,`)
2. Go to **Advanced**
3. Click **Export**
4. Save the file as `raycast-backup.rayconfig` in this directory.

## How to restore
1. Open Raycast Settings
2. Go to **Advanced**
3. Click **Import**
4. Select the `.rayconfig` file from this directory.

## Script Commands
`scripts/` holds Raycast Script Commands (Jira, GitHub PRs, Factorial, Work/Personal mode).

1. Raycast Settings → **Extensions** → **+** → **Add Script Directory** → select `raycast/scripts`.
2. Assign hotkeys or aliases to each command from the same screen.

`work-mode.sh` / `personal-mode.sh` also run the macOS Shortcuts named `Trabajo` / `Personal` when they exist (use them to toggle Focus modes).
