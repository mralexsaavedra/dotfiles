#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils.sh"

print_in_purple "\n • Setting up LaunchAgents...\n"

# Ensure LaunchAgents directory exists
mkdir -p "$HOME/Library/LaunchAgents"

# launchd needs absolute paths in ProgramArguments, so each agent is generated from its
# template (macos/*.plist, __DOTFILES_DIR__ placeholder) instead of being symlinked.
install_agent() {
    local name=$1 src="$DOTFILES_DIR/macos/$1.plist" dest="$HOME/Library/LaunchAgents/$1.plist"
    if [ ! -f "$src" ]; then
        print_error "$name plist not found at" "$src"
        return 1
    fi
    local escaped
    escaped=$(printf '%s\n' "$DOTFILES_DIR" | sed 's/[\/&]/\\&/g')
    # The destination may be an old symlink to the template: writing through it would empty the template.
    rm -f "$dest"
    sed "s|__DOTFILES_DIR__|$escaped|g" "$src" > "$dest"
    chmod 644 "$dest"
    if ! plutil -lint "$dest" >/dev/null; then
        print_error "Generated plist is invalid:" "$dest"
        return 1
    fi
    # Reload it to ensure latest config is active
    launchctl unload "$dest" 2>/dev/null || true
    launchctl load -w "$dest"
    print_success "$name configured and loaded"
}

# 1. Audio Fix Agent
install_agent com.alex.audiofix

# 2. Daily update (brew + gentle-ai, weekdays 08:00)
install_agent com.alex.daily-update
