#!/usr/bin/env bash
# sync-ides.sh: Sync layered config across VSCode and Cursor

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

source "$SCRIPT_DIR/utils.sh"

# Standard macOS IDE configuration paths
VSCODE_PATH="$HOME/Library/Application Support/Code/User"
CURSOR_PATH="$HOME/Library/Application Support/Cursor/User"

# Layered Source of Truth (Git Repo)
DOTFILES_IDES="$DOTFILES_DIR/ides"
DOTFILES_IDES_BASE="$DOTFILES_IDES/base"
DOTFILES_IDES_EDITORS="$DOTFILES_IDES/editors"
DOTFILES_IDES_AI="$DOTFILES_IDES/ai"

resolve_layer_file() {
    local editor_slug="$1"
    local file_name="$2"
    local editor_file="$DOTFILES_IDES_EDITORS/$editor_slug/$file_name"
    local base_file="$DOTFILES_IDES_BASE/$file_name"

    # Editor layer must be a real file (delta), not a symlink to base.
    if [ -f "$editor_file" ] && [ ! -L "$editor_file" ]; then
        printf "%s" "$editor_file"
    else
        printf "%s" "$base_file"
    fi
}

validate_source_file() {
    local source_file="$1"
    local label="$2"

    if [ ! -f "$source_file" ]; then
        print_error "Missing $label source file: $source_file"
        return 1
    fi
}

ensure_link() {
    local target_file="$1"
    local source_file="$2"
    local label="$3"

    if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        mv "$target_file" "$target_file.backup.$(date +%s)"
        print_in_blue "  Backup created for old $label"
    fi

    ln -sf "$source_file" "$target_file"
    print_success "$label linked successfully."
}

install_extensions_from_file() {
    local app_name="$1"
    local binary="$2"
    local extension_file="$3"
    local installed_extensions_ref="$4"

    if [ ! -f "$extension_file" ]; then
        printf "%s" "$installed_extensions_ref"
        return 0
    fi

    while IFS= read -r extension || [ -n "$extension" ]; do
        # Ignore empty lines or comments
        [[ -z "$extension" || "$extension" =~ ^# ]] && continue

        if grep -Fxiq -- "$extension" <<< "$installed_extensions_ref"; then
            continue
        fi

        print_in_purple "    + Installing $extension ($app_name)..."
        "$binary" --install-extension "$extension" --force &> /dev/null
        installed_extensions_ref="$installed_extensions_ref"$'\n'"$extension"
    done < "$extension_file"

    printf "%s" "$installed_extensions_ref"
}

install_extensions() {
    local app_name="$1"
    local binary="$2"
    local editor_slug="$3"

    if cmd_exists "$binary"; then
        print_in_blue "  Verifying extensions for $app_name..."

        local installed_extensions=""
        if ! installed_extensions="$($binary --list-extensions 2>/dev/null)"; then
            print_warning "Could not list installed extensions for $app_name. Continuing with install attempts."
        fi

        installed_extensions="$(install_extensions_from_file "$app_name" "$binary" "$DOTFILES_IDES_BASE/extensions.txt" "$installed_extensions")"
        installed_extensions="$(install_extensions_from_file "$app_name" "$binary" "$DOTFILES_IDES_EDITORS/$editor_slug/extensions.txt" "$installed_extensions")"
        installed_extensions="$(install_extensions_from_file "$app_name" "$binary" "$DOTFILES_IDES_AI/copilot/extensions.txt" "$installed_extensions")"

        print_success "Extensions synced."
    else
        print_in_yellow "  CLI '$binary' not found in PATH (Install extensions skipped)."
    fi
}

sync_config() {
    local app_name="$1"
    local editor_slug="$2"
    local config_dir="$3"
    local binary="$4"

    local settings_source
    local keybindings_source
    settings_source="$(resolve_layer_file "$editor_slug" "settings.json")"
    keybindings_source="$(resolve_layer_file "$editor_slug" "keybindings.json")"

    validate_source_file "$settings_source" "settings.json" || return 1
    validate_source_file "$keybindings_source" "keybindings.json" || return 1

    print_in_purple "\n🔎 Syncing $app_name..."

    if [ ! -d "$config_dir" ]; then
        print_in_blue "  Creating directory: $config_dir"
        mkdir -p "$config_dir"
    fi

    ensure_link "$config_dir/settings.json" "$settings_source" "settings.json"
    ensure_link "$config_dir/keybindings.json" "$keybindings_source" "keybindings.json"

    install_extensions "$app_name" "$binary" "$editor_slug"
}

# --- MAIN ---

print_in_purple "\n🚀 Starting IDE Synchronization (layered mode)...\n"
print_in_blue "Source of Truth: $DOTFILES_IDES"
print_in_blue "Model: base (canonical) + editors/<name> deltas + ai/copilot layer"

sync_config "VSCode" "vscode" "$VSCODE_PATH" "code"
sync_config "Cursor" "cursor" "$CURSOR_PATH" "cursor"
print_success "\n✨ Sync Complete. VSCode/Cursor now use layered config."
