# Daily update — Claude scheduled task (macOS)

Run by the Claude desktop app's local scheduled task `daily-update` (weekdays 08:00, "Solo en este ordenador", folder `~/Developer/dotfiles`). It replaced the `com.alex.daily-update` LaunchAgent on 2026-11-18. The dev LXC keeps its systemd timer (there is no Claude desktop app for Linux).

Talk to the owner in Spanish (Spain). Keep it short.

1. Run `bash scripts/daily-update.sh` in the foreground and wait for it (a few minutes). It writes only to `~/Library/Logs/daily-update.log`; it pulls dotfiles, runs `brew update` + `brew upgrade`, `gentle-ai sync`, restarts `engram serve` if it was upgraded and runs `brew cleanup`.
2. Read this run's part of the log: from the last line that starts with `=== ` to the end.
3. Report:
   - All fine: one line, for example "Actualización diaria: 4 paquetes (gentle-ai 1.2 → 1.3, …), gentle-ai sincronizado".
   - Something failed (a `Problems:` line, or errors in the log): say what failed and why, from the log and read-only checks (`git -C ~/Developer/dotfiles status`, `brew outdated`, `brew doctor`, …), and propose the exact fix.
4. Never apply a fix that needs a password or sudo, discards or overwrites local changes (`git reset`, `git checkout --`, `git stash`, force pulls), uninstalls or deletes anything, without the owner's explicit OK in this session. Casks that ask for an admin password cannot be upgraded here: list them so the owner runs `brew upgrade --cask <name>` in a terminal.
