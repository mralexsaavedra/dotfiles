#!/usr/bin/env bash

# OS X Config File - Alexander Saavedra
# This file handles all my configuration for the OS X system that I'm using like preferences and other stuff.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/scripts/utils.sh"

install_gh_extension() {
    local extension="$1"

    if gh extension list 2>/dev/null | grep -Fq "$extension"; then
        print_success "GitHub extension already present: $extension"
        return 0
    fi

    if gh extension install "$extension" &>/dev/null; then
        print_success "Installed GitHub extension: $extension"
    else
        print_warning "Could not install GitHub extension: $extension"
    fi
}

clear
print_in_purple '\nOS X Config Dotfiles - Alexander Saavedra\n\n'
ask_for_sudo

chmod u+x "$SCRIPT_DIR"/scripts/*.sh

"$SCRIPT_DIR/scripts/computer-info.sh"
"$SCRIPT_DIR/scripts/ssh-setup.sh"
"$SCRIPT_DIR/scripts/osx-preferences.sh"
"$SCRIPT_DIR/scripts/xcode-install.sh"
"$SCRIPT_DIR/scripts/brew-install.sh"
"$SCRIPT_DIR/scripts/brew-packages.sh"
"$SCRIPT_DIR/scripts/zsh-ohmyzsh.sh"

stow -t "$HOME" -v ghostty git zsh starship gh vim --adopt

# Ensure ~/bin exists before stowing to verify proper linking or link directly
mkdir -p "$HOME/bin"
stow -t "$HOME" -v bin --adopt

# GitHub CLI Extensions
if cmd_exists "gh"; then
    print_in_purple "\n • Installing GitHub CLI extensions...\n"
    install_gh_extension "dlvhdr/gh-dash"
    install_gh_extension "github/gh-copilot"
    install_gh_extension "seachicken/gh-poi"
fi

# Sync IDEs (VSCode, Cursor, Windsurf)
"$SCRIPT_DIR/scripts/sync-ides.sh"

# System Services
"$SCRIPT_DIR/scripts/setup-services.sh"

# Restart
"$SCRIPT_DIR/scripts/restart.sh"
