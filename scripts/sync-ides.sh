#!/usr/bin/env bash

source './scripts/utils.sh'

# Rutas estándar de los IDEs en macOS
VSCODE_PATH="$HOME/Library/Application Support/Code/User"
CURSOR_PATH="$HOME/Library/Application Support/Cursor/User"
WINDSURF_PATH="$HOME/Library/Application Support/Windsurf/User"

# Ruta del repositorio (fuente de la verdad)
DOTFILES_IDES="$HOME/Developer/dotfiles/ides"

# Función para sincronizar configuración
sync_config() {
    local app_name=$1
    local target_path=$2
    local binary=$3

    if [ -d "$target_path" ]; then
        print_in_purple "\n🔎 Sincronizando $app_name..."

        # 1. Settings.json
        if [ -L "$target_path/settings.json" ]; then
            print_success "settings.json ya está enlazado."
        else
            if [ -f "$target_path/settings.json" ]; then
                mv "$target_path/settings.json" "$target_path/settings.json.backup.$(date +%s)"
                print_in_blue "  Backup creado para settings.json antiguo"
            fi
            ln -sf "$DOTFILES_IDES/settings.json" "$target_path/settings.json"
            print_success "settings.json enlazado correctamente."
        fi

        # 2. Keybindings.json
        if [ -L "$target_path/keybindings.json" ]; then
            print_success "keybindings.json ya está enlazado."
        else
             if [ -f "$target_path/keybindings.json" ]; then
                mv "$target_path/keybindings.json" "$target_path/keybindings.json.backup.$(date +%s)"
                print_in_blue "  Backup creado para keybindings.json antiguo"
            fi
            ln -sf "$DOTFILES_IDES/keybindings.json" "$target_path/keybindings.json"
            print_success "keybindings.json enlazado correctamente."
        fi

        # 3. Snippets (Opcional, enlazamos la carpeta entera si existe)
        # ln -sf "$DOTFILES_IDES/snippets" "$target_path/snippets"

        # 4. Extensiones
        install_extensions "$app_name" "$binary"
    else
        print_error "$app_name no detectado en $target_path (Saltando...)"
    fi
}

# Función para instalar extensiones
install_extensions() {
    local app_name=$1
    local binary=$2

    if cmd_exists "$binary"; then
        print_in_blue "  Instalando extensiones para $app_name..."
        while IFS= read -r extension || [ -n "$extension" ]; do
            # Ignorar líneas vacías o comentarios
            [[ -z "$extension" || "$extension" =~ ^# ]] && continue
            
            # Instalar (silenciosamente si ya existe)
            # Nota: Windsurf y Cursor a veces usan flags distintos, pero suelen respetar --install-extension
            $binary --install-extension "$extension" --force &> /dev/null
        done < "$DOTFILES_IDES/extensions.txt"
        print_success "Extensiones sincronizadas."
    else
        print_in_yellow "  CLI '$binary' no encontrado en el PATH. No se pueden instalar extensiones auto."
    fi
}

# --- MAIN ---

print_in_purple "\n🚀 Iniciando Sincronización de IDEs...\n"
print_in_blue "Fuente de la Verdad: $DOTFILES_IDES"

# Sincronizar VSCode
sync_config "VSCode" "$VSCODE_PATH" "code"

# Sincronizar Cursor
sync_config "Cursor" "$CURSOR_PATH" "cursor"

# Sincronizar Windsurf (El binario suele ser 'windsurf')
sync_config "Windsurf" "$WINDSURF_PATH" "windsurf"

print_success "\n✨ Sincronización completada. Tus IDEs ahora comparten cerebro."
