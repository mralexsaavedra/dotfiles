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

# --- 5. NVM (Node Version Manager) ---
# Nota: NVM es un poco lento al arrancar. Está bien aquí, pero fnm es más rápido.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- 6. PLUGINS VISUALES Y STARSHIP (AL FINAL) ---

# Autosuggestions & Syntax Highlighting (Vía Homebrew)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Esto fuerza a que los comentarios (# texto) usen la cursiva 'ss01' de Cascadia
ZSH_HIGHLIGHT_STYLES[comment]='fg=gray,italic'
# Opcional: palabras clave también en cursiva
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta,italic'

# Iniciar Starship (El prompt visual)
eval "$(starship init zsh)"