#!/usr/bin/env bash

set -euo pipefail

# Linux counterpart of setup-services.sh: installs the systemd user units from linux/systemd/.
# Run by the Homebrew owner (daily-update runs brew upgrade), after `loginctl enable-linger`.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils.sh"

UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"

if ! systemctl --user show-environment >/dev/null 2>&1; then
    print_warning "No systemd user session here (container or no linger); skipping user units." ""
    exit 0
fi

print_in_purple "\n • Setting up systemd user units...\n"
mkdir -p "$UNIT_DIR"

# Units need absolute paths, so they are generated from templates (__DOTFILES_DIR__), as on macOS.
escaped=$(printf '%s\n' "$DOTFILES_DIR" | sed 's/[\/&]/\\&/g')
for src in "$DOTFILES_DIR"/linux/systemd/*; do
    dest="$UNIT_DIR/$(basename "$src")"
    rm -f "$dest"
    sed "s|__DOTFILES_DIR__|$escaped|g" "$src" > "$dest"
done

systemctl --user daemon-reload
systemctl --user enable --now daily-update.timer
print_success "daily-update.timer enabled"
