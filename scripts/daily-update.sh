#!/bin/bash
# Unattended morning update, run by the com.alex.daily-update LaunchAgent (weekdays 08:00,
# or on wake if the Mac was asleep). Log: ~/Library/Logs/daily-update.log
#   1. brew update + upgrade (also updates gentle-ai, engram and gga from their taps)
#   2. gentle-ai sync
#   3. restart `engram serve` when the running daemon is older than the installed binary
#   4. brew cleanup
# Ends with a macOS notification summarising what changed or failed.
# For the interactive version with Brewfile dump, use `make update`.

set -uo pipefail
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export HOMEBREW_NO_ENV_HINTS=1

LOG="$HOME/Library/Logs/daily-update.log"
exec >> "$LOG" 2>&1
echo "=== $(date '+%Y-%m-%d %H:%M:%S') daily update ==="

problems=()
notify() { osascript -e "display notification \"$2\" with title \"$1\"" 2>/dev/null || true; }

# 1. Homebrew
upgraded=0
if brew update; then
  outdated=$(brew outdated --quiet)
  upgraded=$(printf '%s' "$outdated" | grep -c . || true)
  if [ "$upgraded" -gt 0 ]; then
    echo "Outdated: $(echo "$outdated" | tr '\n' ' ')"
    # Casks that need an admin password fail without a terminal; the rest still upgrade.
    brew upgrade || problems+=("brew upgrade (see log)")
  fi
else
  problems+=("brew update")
fi

# 2. gentle-ai
if command -v gentle-ai >/dev/null; then
  gentle-ai sync || problems+=("gentle-ai sync")
fi

# 3. engram daemon running an older version than the installed binary
if command -v engram >/dev/null && pgrep -f 'engram serve' >/dev/null; then
  installed=$(engram --version 2>/dev/null | awk '{print $2}')
  running=$(curl -s --max-time 3 http://127.0.0.1:7437/health | jq -r '.version // empty' 2>/dev/null)
  if [ -n "$installed" ] && [ -n "$running" ] && [ "$installed" != "$running" ]; then
    echo "Restarting engram serve: $running -> $installed"
    pkill -TERM -f 'engram serve'
    for _ in $(seq 1 20); do pgrep -f 'engram serve' >/dev/null || break; sleep 0.5; done
    nohup engram serve >/dev/null 2>&1 &
  fi
fi

# 4. Cleanup
brew cleanup >/dev/null 2>&1 || true

# Summary
summary="$upgraded paquete(s) actualizados · gentle-ai sincronizado"
[ "$upgraded" -eq 0 ] && summary="Todo al día · gentle-ai sincronizado"
if [ ${#problems[@]} -gt 0 ]; then
  notify "Actualización diaria: revisar" "Fallo en: ${problems[*]}. Log: ~/Library/Logs/daily-update.log"
  echo "Problems: ${problems[*]}"
else
  notify "Actualización diaria" "$summary"
fi
echo "Done: $summary"
