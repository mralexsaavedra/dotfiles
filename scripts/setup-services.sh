#!/bin/bash
source "$(dirname "$0")/utils.sh"

print_in_purple "\n • Setting up LaunchAgents...\n"

# Ensure LaunchAgents directory exists
mkdir -p "$HOME/Library/LaunchAgents"

DOTFILES_DIR="$HOME/Developer/dotfiles"
PLIST_SRC="$DOTFILES_DIR/macos/com.alex.audiofix.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.alex.audiofix.plist"

# 1. Audio Fix Agent
if [ -f "$PLIST_SRC" ]; then
    ln -sf "$PLIST_SRC" "$PLIST_DEST"
    
    # Reload it to ensure latest config is active
    launchctl unload "$PLIST_DEST" 2>/dev/null
    launchctl load -w "$PLIST_DEST"
    
    print_success "Audio Fix Agent configured and loaded"
else
    print_error "Audio Fix plist not found at $PLIST_SRC"
fi
