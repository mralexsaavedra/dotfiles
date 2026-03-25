#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils.sh"

print_in_purple "\n • Setting up LaunchAgents...\n"

# Ensure LaunchAgents directory exists
mkdir -p "$HOME/Library/LaunchAgents"

PLIST_SRC="$DOTFILES_DIR/macos/com.alex.audiofix.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.alex.audiofix.plist"

# 1. Audio Fix Agent
if [ -f "$PLIST_SRC" ]; then
    # launchd needs absolute paths in ProgramArguments.
    # We generate a machine-local plist from the template instead of symlinking it.
    ESCAPED_DOTFILES_DIR=$(printf '%s\n' "$DOTFILES_DIR" | sed 's/[\/&]/\\&/g')
    sed "s|__DOTFILES_DIR__|$ESCAPED_DOTFILES_DIR|g" "$PLIST_SRC" > "$PLIST_DEST"
    chmod 644 "$PLIST_DEST"

    if ! plutil -lint "$PLIST_DEST" >/dev/null; then
        print_error "Generated plist is invalid: $PLIST_DEST"
        exit 1
    fi
    
    # Reload it to ensure latest config is active
    launchctl unload "$PLIST_DEST" 2>/dev/null
    launchctl load -w "$PLIST_DEST"
    
    print_success "Audio Fix Agent configured and loaded"
else
    print_error "Audio Fix plist not found at $PLIST_SRC"
fi
