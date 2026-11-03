#!/usr/bin/env bash

# Linux setup (homelab `dev` LXC, Debian/Ubuntu). Called by ./setup.sh on Linux.
#
#   ./setup.sh --machine   Once per machine, by the admin user (needs sudo): apt prerequisites,
#                          shared Homebrew (/home/linuxbrew/.linuxbrew), brew/Brewfile.linux,
#                          zsh as login shell, systemd linger and the daily-update user timer.
#                          Then runs the per-user steps for that same user.
#   ./setup.sh             Once per user, no sudo (agent users have none): Oh My Zsh, stow
#                          packages, Claude Code, local MCP servers, gentle-ai sync.
#
# Both modes refuse root: Homebrew will not run as root, and Claude Code refuses
# bypass permissions as root.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$SCRIPT_DIR/utils.sh"

BREW_PREFIX="/home/linuxbrew/.linuxbrew"
# ghostty is a GUI terminal: Mac only.
STOW_PACKAGES=(git zsh gh vim claude-code bin)

usage() {
    echo "Usage: ./setup.sh [--machine]"
}

load_brew() {
    if [[ -x "$BREW_PREFIX/bin/brew" ]]; then
        eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    fi
}

machine_setup() {
    print_in_purple "\n • Machine setup (sudo)...\n"
    sudo apt-get update
    sudo apt-get install -y build-essential procps curl file git zsh stow ca-certificates locales

    # .zshenv exports en_US.UTF-8: make sure the locale exists.
    if ! locale -a 2>/dev/null | grep -qi '^en_US\.utf8$'; then
        sudo sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        sudo locale-gen
    fi

    if [[ ! -x "$BREW_PREFIX/bin/brew" ]]; then
        print_in_purple "\n • Installing Homebrew...\n"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    load_brew
    # One failed formula must not stop the rest of the setup; it is reported above.
    brew bundle install --file="$DOTFILES_DIR/brew/Brewfile.linux" ||
        print_warning "Some Brewfile.linux formulas failed; see the brew output above." ""

    if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
        sudo chsh -s /usr/bin/zsh "$USER"
    fi

    # Let user services (daily-update timer, agent daemons) run without an open session.
    sudo loginctl enable-linger "$USER" ||
        print_warning "loginctl enable-linger failed (no systemd here?); user services need it." ""
    "$SCRIPT_DIR/setup-services-linux.sh"
}

install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh is already installed."
        return
    fi
    print_in_purple "\n • Installing Oh My Zsh...\n"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    # The installer writes its own .zshrc; remove it so stow can link ours.
    rm -f "$HOME/.zshrc"
}

stow_packages() {
    print_in_purple "\n • Linking dotfiles...\n"
    # Real directories first: if they were missing, stow would link the whole directory and
    # every file Claude Code or gh writes there would land inside this repo.
    mkdir -p "$HOME/.claude" "$HOME/.config" "$HOME/bin"
    # No --adopt (unlike macOS): on a conflict, stop instead of pulling the user's file into the repo.
    # CLAUDE.md is copied, not linked (as on the Mac): gentle-ai sync refuses to write through a
    # symlink, and it keeps the copy's user blocks (such as the es-ES override) when it updates it.
    stow -d "$DOTFILES_DIR" -t "$HOME" -v --ignore='CLAUDE\.md' "${STOW_PACKAGES[@]}"
    if [[ ! -e "$HOME/.claude/CLAUDE.md" ]]; then
        cp "$DOTFILES_DIR/claude-code/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    fi
}

install_claude_code() {
    export PATH="$HOME/.local/bin:$PATH"
    if command -v claude >/dev/null 2>&1; then
        print_success "Claude Code is already installed."
        return
    fi
    print_in_purple "\n • Installing Claude Code...\n"
    curl -fsSL https://claude.ai/install.sh | bash
}

# Same local MCP servers as the Mac (user scope, idempotent).
add_mcp_servers() {
    command -v claude >/dev/null 2>&1 || return 0
    print_in_purple "\n • Configuring MCP servers...\n"
    if ! claude mcp get engram >/dev/null 2>&1 && command -v engram >/dev/null 2>&1; then
        claude mcp add --scope user engram -- "$(command -v engram)" mcp --tools=agent
    fi
    if ! claude mcp get codegraph >/dev/null 2>&1 && command -v codegraph >/dev/null 2>&1; then
        claude mcp add --scope user codegraph -- codegraph serve --mcp
    fi
    if ! claude mcp get context7 >/dev/null 2>&1; then
        claude mcp add --scope user --transport http context7 https://mcp.context7.com/mcp
    fi
}

# settings.json is not in dotfiles (Claude Code and gentle-ai write to it): only set the status line.
configure_statusline() {
    local settings="$HOME/.claude/settings.json" tmp
    [[ -f "$settings" ]] || echo '{}' > "$settings"
    # shellcheck disable=SC2088  # literal "~": that is the value stored in settings.json
    if [[ "$(jq -r '.statusLine.command // empty' "$settings")" != "~/.claude/statusline.sh" ]]; then
        tmp=$(mktemp)
        jq '.statusLine = {"type": "command", "command": "~/.claude/statusline.sh", "padding": 0}' "$settings" > "$tmp"
        mv "$tmp" "$settings"
        print_success "Status line configured"
    fi
    # Shared settings tracked from the Mac (`make sync-ai`): effortLevel and permissions. The deny
    # rules keep Claude from reading .env files, SSH keys and credentials. Arrays are replaced.
    tmp=$(mktemp)
    jq -s '.[0] * .[1]' "$settings" "$DOTFILES_DIR/claude-code-settings/settings.shared.json" > "$tmp"
    mv "$tmp" "$settings"
    print_success "Shared settings applied (effortLevel, permissions)"
}

# Same marketplaces and plugins as the Mac (~/.claude/settings.json enabledPlugins), minus
# warp@claude-code-warp, which only works inside the Warp terminal.
MARKETPLACES=(anthropics/claude-plugins-official Gentleman-Programming/engram midudev/better-claude)
PLUGINS=(engram@engram claude-code-setup@claude-plugins-official
    after@better-claude commit@better-claude image-preview@better-claude narrator@better-claude
    sub-meter@better-claude think-hard@better-claude token-meter@better-claude use-haiku@better-claude)

install_plugins() {
    command -v claude >/dev/null 2>&1 || return 0
    print_in_purple "\n • Installing Claude Code plugins...\n"
    local repo plugin installed
    for repo in "${MARKETPLACES[@]}"; do
        claude plugin marketplace add "$repo" >/dev/null 2>&1 || true   # already added is fine
    done
    installed=$(claude plugin list 2>/dev/null || true)
    for plugin in "${PLUGINS[@]}"; do
        if grep -qF "$plugin" <<< "$installed"; then
            continue
        fi
        claude plugin install "$plugin" || print_warning "Could not install plugin" "$plugin"
    done
    # Same plugin options as the Mac (settings.json pluginConfigs).
    local settings="$HOME/.claude/settings.json" tmp
    tmp=$(mktemp)
    jq '.pluginConfigs["narrator@better-claude"].options.language = "es"' "$settings" > "$tmp"
    mv "$tmp" "$settings"
}

# The tracked .gitconfig uses the macOS keychain helper and signs commits with
# ~/.ssh/id_ed25519. On Linux, GitHub credentials come from gh instead, written to
# ~/.gitconfig.user (included by .gitconfig; never write to ~/.gitconfig, it is the repo file).
configure_git() {
    local user_cfg="$HOME/.gitconfig.user" gh_bin
    gh_bin=$(command -v gh) || return 0
    if ! git config --file "$user_cfg" --get-all credential.https://github.com.helper >/dev/null 2>&1; then
        # The empty value resets the inherited osxkeychain helper for github.com.
        git config --file "$user_cfg" --add credential.https://github.com.helper ""
        git config --file "$user_cfg" --add credential.https://github.com.helper "!$gh_bin auth git-credential"
        print_success "Git uses gh for GitHub credentials ($user_cfg)"
    fi
    if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
        print_warning "No ~/.ssh/id_ed25519: commits are signed with it (.gitconfig), so they will fail." \
            "Create one and add it to GitHub as a signing key (see README)."
    fi
}

# Engram Cloud reads ENGRAM_CLOUD_SERVER/TOKEN/AUTOSYNC from ~/.zshenv.local, as on the Mac.
# The token is a secret: the owner writes that file (chmod 600); it is never in this repo.
check_engram_cloud() {
    local env_file="$HOME/.zshenv.local"
    if [[ -f "$env_file" ]] && grep -q '^export ENGRAM_CLOUD_TOKEN=' "$env_file"; then
        chmod 600 "$env_file"
        print_success "Engram Cloud configured in $env_file"
    else
        print_warning "Engram Cloud not configured. Write $env_file (chmod 600) with ENGRAM_CLOUD_SERVER," \
            "ENGRAM_CLOUD_TOKEN and ENGRAM_CLOUD_AUTOSYNC (see zsh/.zshenv.local.example), then: engram cloud enroll <project>"
    fi
}

user_setup() {
    print_in_purple "\n • User setup for $USER...\n"
    load_brew
    install_oh_my_zsh
    stow_packages
    install_claude_code
    configure_statusline
    add_mcp_servers
    # rtk PreToolUse hook + ~/.claude/RTK.md (CLAUDE.md includes it with @RTK.md), as on the Mac.
    if command -v rtk >/dev/null 2>&1; then
        rtk init -g --auto-patch --no-trust-filters || print_warning "rtk init failed; run: rtk init -g" ""
    fi
    install_plugins
    configure_git
    check_engram_cloud
    if command -v gentle-ai >/dev/null 2>&1; then
        gentle-ai sync || print_warning "gentle-ai sync failed; run it again by hand." ""
    fi
    if [[ "$(getent passwd "$USER" | cut -d: -f7)" != */zsh ]]; then
        print_warning "Login shell is not zsh. An admin can run: sudo chsh -s /usr/bin/zsh $USER" ""
    fi
    print_success "Done. Open a new shell to load the config."
}

if [[ $EUID -eq 0 ]]; then
    print_error "Run this as a normal user, not root." ""
    exit 1
fi

case "${1:-}" in
    --machine) machine_setup; user_setup ;;
    "") user_setup ;;
    -h|--help) usage ;;
    *) usage; exit 1 ;;
esac
