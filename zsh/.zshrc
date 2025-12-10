# --- 1. CONFIGURACIÓN BÁSICA ---
export ZSH="$HOME/.oh-my-zsh"

# Desactivamos el tema de OMZ porque usamos Starship (es más rápido no cargar nada aquí)
ZSH_THEME=""

# --- 2. PLUGINS DE OH MY ZSH ---
# Agregué 'z' (navegación rápida) y 'sudo' (doble Esc pone sudo al comando actual)
# 'git' ya lo tenías.
plugins=(git z sudo)

source $ZSH/oh-my-zsh.sh

# --- 3. VARIABLES DE ENTORNO Y PATHS ---
export LANG=en_US.UTF-8

# Definir Brew Prefix una sola vez para optimizar carga
if type brew &>/dev/null; then
  export BREW_PREFIX="$(brew --prefix)"
else
  # Fallback comun en Apple Silicon / Intel
  if [ -d "/opt/homebrew" ]; then
    export BREW_PREFIX="/opt/homebrew"
  else
    export BREW_PREFIX="/usr/local"
  fi
fi

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Antigravity & Windsurf
export PATH="/Users/mralexsaavedra/.antigravity/antigravity/bin:$PATH"
export PATH="/Users/mralexsaavedra/.codeium/windsurf/bin:$PATH"

# --- 4. CONFIGURACIÓN EXTRA ---

# Cargar alias externos
[ -f "$HOME/.aliases" ] && source $HOME/.aliases

# Cargar variables .env (si existe)
if [ -f "$HOME/.env" ]; then
  export $(grep -v '^#' "$HOME/.env" | xargs)
fi

# Navegación inteligente por historial (Flecha arriba/abajo busca lo que escribiste)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# --- 5. HERRAMIENTAS MODERNAS (FNM & ZOXIDE) ---
# FNM (Fast Node Manager) - Reemplazo de NVM
if command -v fnm 1>/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# Zoxide - Reemplazo inteligente de cd
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# FZF - Búsqueda borrosa
if command -v fzf 1>/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# --- 6. PLUGINS VISUALES Y STARSHIP (AL FINAL) ---

# Autosuggestions & Syntax Highlighting (Vía Homebrew)
if [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Esto fuerza a que los comentarios (# texto) usen la cursiva 'ss01' de Cascadia
ZSH_HIGHLIGHT_STYLES[comment]='fg=gray,italic'
# Opcional: palabras clave también en cursiva
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta,italic'

# Iniciar Starship (El prompt visual)
eval "$(starship init zsh)"