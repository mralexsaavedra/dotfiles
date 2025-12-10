# --- 1. BASIC CONFIGURATION ---
export ZSH="$HOME/.oh-my-zsh"

# Disable OMZ theme because we use Starship (faster to load nothing here)
ZSH_THEME=""

# --- 2. OH MY ZSH PLUGINS ---
# Added 'z' (fast navigation) and 'sudo' (double Esc adds sudo to current command)
# 'git' was already there.
plugins=(git z sudo)

source $ZSH/oh-my-zsh.sh

# --- 3. EXTRA CONFIGURATION ---

# Load external aliases and functions
[ -f "$HOME/.aliases" ] && source $HOME/.aliases
[ -f "$HOME/.functions" ] && source $HOME/.functions

# Load .env variables (if exists)
if [ -f "$HOME/.env" ]; then
  export $(grep -v '^#' "$HOME/.env" | xargs)
fi

# Smart History Navigation (Up/Down arrow searches what you typed)
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# --- 5. MODERN TOOLS (FNM & ZOXIDE) ---
# FNM (Fast Node Manager) - NVM replacement
if command -v fnm 1>/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# Zoxide - Smart cd replacement
if command -v zoxide 1>/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# FZF - Fuzzy Finder
if command -v fzf 1>/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# --- 6. VISUAL PLUGINS & STARSHIP (AT THE END) ---

# Autosuggestions & Syntax Highlighting (Via Homebrew)
if [ -f "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Force comments (# text) to use 'ss01' italic variant of Cascadia
ZSH_HIGHLIGHT_STYLES[comment]='fg=gray,italic'
# Optional: keywords in italic too
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue,italic'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta,italic'

# Initialize Starship (The visual prompt)
eval "$(starship init zsh)"