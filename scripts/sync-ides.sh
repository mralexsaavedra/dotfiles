#!/usr/bin/env bash
# sync-ides.sh: Unifies configuration across VSCode, Cursor, and Windsurf

source './scripts/utils.sh'

# Standard macOS IDE Configuration Paths
VSCODE_PATH="$HOME/Library/Application Support/Code/User"
CURSOR_PATH="$HOME/Library/Application Support/Cursor/User"
WINDSURF_PATH="$HOME/Library/Application Support/Windsurf/User"

# Source of Truth (Git Repo)
DOTFILES_IDES="$HOME/Developer/dotfiles/ides"

# Function to perform the sync
sync_config() {
    local app_name=$1
    local config_dir=$2
    local binary=$3

    print_in_purple "\n🔎 Syncing $app_name..."

    # Ensure the User config directory exists (even if app not installed yet, prep it)
    if [ ! -d "$config_dir" ]; then
        print_in_blue "  Creating directory: $config_dir"
        mkdir -p "$config_dir"
    fi

    # 1. Settings.json
    if [ -L "$config_dir/settings.json" ]; then
        print_success "settings.json is already linked."
    else
        # Back up existing file if it's a real file (not a link)
        if [ -f "$config_dir/settings.json" ]; then
            mv "$config_dir/settings.json" "$config_dir/settings.json.backup.$(date +%s)"
            print_in_blue "  Backup created for old settings.json"
        fi
        ln -sf "$DOTFILES_IDES/settings.json" "$config_dir/settings.json"
        print_success "settings.json linked successfully."
    fi

    # 2. Keybindings.json
    if [ -L "$config_dir/keybindings.json" ]; then
        print_success "keybindings.json is already linked."
    else
         if [ -f "$config_dir/keybindings.json" ]; then
            mv "$config_dir/keybindings.json" "$config_dir/keybindings.json.backup.$(date +%s)"
            print_in_blue "  Backup created for old keybindings.json"
        fi
        ln -sf "$DOTFILES_IDES/keybindings.json" "$config_dir/keybindings.json"
        print_success "keybindings.json linked successfully."
    fi

    # 3. Extensions
    install_extensions "$app_name" "$binary"
}

# Function to install extensions efficiently
install_extensions() {
    local app_name=$1
    local binary=$2

    if cmd_exists "$binary"; then
        print_in_blue "  Verifying extensions for $app_name..."
        
        # Get list of currently installed extensions (to avoid re-installing and crashing Electron)
        local installed_extensions=$($binary --list-extensions)

        while IFS= read -r extension || [ -n "$extension" ]; do
            # Ignore empty lines or comments
            [[ -z "$extension" || "$extension" =~ ^# ]] && continue
            
            # Check if already installed (silent grep)
            if echo "$installed_extensions" | grep -qi "^$extension$"; then
                # Already installed, skip
                :
            else
                print_in_purple "    + Installing $extension..."
                $binary --install-extension "$extension" --force &> /dev/null
            fi
        done < "$DOTFILES_IDES/extensions.txt"
        print_success "Extensions synced."
    else
        print_in_yellow "  CLI '$binary' not found in PATH (Install extensions skipped)."
    fi
}

# --- MAIN ---

print_in_purple "\n🚀 Starting IDE Synchronization...\n"
print_in_blue "Source of Truth: $DOTFILES_IDES"

# Sync VSCode
sync_config "VSCode" "$VSCODE_PATH" "code"

# Sync Cursor
sync_config "Cursor" "$CURSOR_PATH" "cursor"

# Sync Windsurf
sync_config "Windsurf" "$WINDSURF_PATH" "windsurf"

print_success "\n✨ Sync Complete. Your IDEs now share the same brain."
