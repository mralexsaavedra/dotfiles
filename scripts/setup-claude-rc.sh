#!/usr/bin/env bash
# Installs one Claude Code Remote Control LaunchAgent per repository (macOS), from the template
# macos/com.alex.claude-rc.plist. Each folder then appears under Code > Devices in the Claude app.
#
# Usage: setup-claude-rc.sh [-n]   (-n: dry run, print what would change)
#
# A folder must be trusted first: run `claude` once in it and accept the trust dialog. Untrusted
# folders are skipped (the server would exit with "Workspace not trusted" and restart every 10 s).
# An agent whose plist did not change is left running, so live sessions are not interrupted.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMPLATE="$DOTFILES_DIR/macos/com.alex.claude-rc.plist"
AGENTS_DIR="$HOME/Library/LaunchAgents"

# Repositories under ~/Developer that get a Remote Control server.
REPOS=(
    cleanyourtv
    declaracion-renta-espana
    dotfiles
    engram
    gentle-ai
    homelab
    lookiero/bo-front
    lookiero/labs-front-legacy
    lookiero/labs-front-legacy-config
    lookiero/sty-sp-front
    lookiero/user-area-front
    lookiero/user-area-front-config
    mac
    manual-connections
    mralexsaavedra.com
    nxnative
)

DRY_RUN=false
[ "${1:-}" = "-n" ] && DRY_RUN=true

# True when the folder or one of its parents has the trust dialog accepted in ~/.claude.json.
is_trusted() {
    local dir=$1
    while [ "$dir" != "/" ]; do
        if [ "$(jq -r --arg p "$dir" '.projects[$p].hasTrustDialogAccepted // false' "$HOME/.claude.json")" = "true" ]; then
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

mkdir -p "$AGENTS_DIR"
untrusted=()
for repo in "${REPOS[@]}"; do
    dir="$HOME/Developer/$repo"
    label="com.alex.claude-rc.${repo//\//.}"
    dest="$AGENTS_DIR/$label.plist"
    if [ ! -d "$dir/.git" ]; then
        echo "skip  $repo (not a git repository)"
        continue
    fi
    if ! is_trusted "$dir"; then
        untrusted+=("$repo")
        echo "skip  $repo (workspace not trusted)"
        continue
    fi
    generated=$(sed -e "s|__LABEL__|$label|g" -e "s|__REPO__|$repo|g" \
        -e "s|__HOME__|$HOME|g" -e "s|__DOTFILES_DIR__|$DOTFILES_DIR|g" "$TEMPLATE")
    if [ -f "$dest" ] && [ "$generated" = "$(cat "$dest")" ] && launchctl list "$label" >/dev/null 2>&1; then
        echo "ok    $repo (unchanged, running)"
        continue
    fi
    if $DRY_RUN; then
        echo "load  $repo -> $dest (dry run)"
        continue
    fi
    printf '%s\n' "$generated" > "$dest"
    chmod 644 "$dest"
    plutil -lint "$dest" >/dev/null
    launchctl unload "$dest" 2>/dev/null || true
    launchctl load -w "$dest"
    echo "load  $repo"
done

if [ ${#untrusted[@]} -gt 0 ]; then
    echo
    echo "Not trusted yet: run \`claude\` once in each folder, accept the trust dialog, then run this script again:"
    printf '  ~/Developer/%s\n' "${untrusted[@]}"
fi
