# =============================================================================
# Gentleman Dots base / bootstrap
# =============================================================================

# [Gentleman Dots base] Powerlevel10k instant prompt (must stay near top).
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# [Gentleman Dots base / bootstrap] Core shell base.
export ZSH="$HOME/.oh-my-zsh"

# [Gentleman Dots base / bootstrap] Termux detection.
IS_TERMUX=0
if [[ -n "$TERMUX_VERSION" || -d "/data/data/com.termux" ]]; then
  IS_TERMUX=1
fi

# [Gentleman Dots base / bootstrap] Helper functions.
source_if_exists() {
  [[ -r "$1" ]] && source "$1"
}

source_first_existing() {
  local file
  for file in "$@"; do
    if [[ -r "$file" ]]; then
      source "$file"
      return 0
    fi
  done
  return 1
}

add_path_if_exists() {
  [[ -d "$1" ]] && path=("$1" $path)
}

# =============================================================================
# Gentleman Dots platform & package manager setup
# =============================================================================

# [Gentleman Dots platform] PATH (deduplicated + defensive).
typeset -U path PATH

if [[ $IS_TERMUX -eq 1 ]]; then
  [[ -n "$PREFIX" ]] && add_path_if_exists "$PREFIX/bin"
  add_path_if_exists "$HOME/.local/bin"
  add_path_if_exists "$HOME/.cargo/bin"
else
  add_path_if_exists "$HOME/.local/bin"
  add_path_if_exists "$HOME/.opencode/bin"
  add_path_if_exists "$HOME/.cargo/bin"
  add_path_if_exists "$HOME/.volta/bin"
  add_path_if_exists "$HOME/.bun/bin"
  add_path_if_exists "$HOME/.nix-profile/bin"
  add_path_if_exists "/nix/var/nix/profiles/default/bin"
  add_path_if_exists "/usr/local/bin"
fi

export PATH

# [Gentleman Dots platform] Homebrew integration (non-Termux, platform-aware).
if [[ $IS_TERMUX -eq 0 ]]; then
  BREW_BIN=""
  for candidate in \
    "/opt/homebrew/bin/brew" \
    "/usr/local/bin/brew" \
    "/home/linuxbrew/.linuxbrew/bin/brew"; do
    if [[ -x "$candidate" ]]; then
      BREW_BIN="$candidate"
      break
    fi
  done

  if [[ -n "$BREW_BIN" ]]; then
    eval "$("$BREW_BIN" shellenv)"
  fi
fi

# =============================================================================
# Gentleman Dots shell framework
# =============================================================================

# [Gentleman Dots shell framework] Oh My Zsh + plugins.
# Keep OMZ plugins minimal and compatible with zoxide (skip plugin 'z').
plugins=(git sudo)

if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

# =============================================================================
# Alexander customizations preserved (from previous ~/.zshrc)
# =============================================================================

# [Alexander customizations preserved] Optional personal aliases/functions.
source_if_exists "$HOME/.aliases"
source_if_exists "$HOME/.functions"

# [Alexander customizations preserved] Advanced history configuration.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

# [Alexander customizations preserved] Smart history navigation (Up/Down by current buffer).
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# =============================================================================
# Shared integrations (portable across setups)
# =============================================================================

# [Shared integrations] Optional shell enhancements with defensive checks.
if command -v fzf >/dev/null 2>&1; then
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
  fi
  eval "$(fzf --zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# =============================================================================
# Alexander preserved Node workflow
# =============================================================================

# [Alexander preserved Node workflow] Restored fnm auto-switch on directory change.
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# =============================================================================
# Shared integrations (portable completion bridge)
# =============================================================================

if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

# =============================================================================
# Gentleman Dots shell plugins & theme sources (optional)
# =============================================================================

# [Gentleman Dots shell] Extra plugin/theme sources (only if present).
source_first_existing \
  "${PREFIX:+$PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh}" \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh}" \
  "/opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" \
  "/usr/local/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

source_first_existing \
  "${PREFIX:+$PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh}" \
  "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

source_first_existing \
  "${PREFIX:+$PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
  "${BREW_PREFIX:+$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh}" \
  "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# [Gentleman Dots shell] Powerlevel10k final theme/config load.
source_first_existing \
  "${PREFIX:+$PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme}" \
  "${BREW_PREFIX:+$BREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme}" \
  "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" \
  "/usr/local/share/powerlevel10k/powerlevel10k.zsh-theme" \
  "/home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme"
source_if_exists "$HOME/.p10k.zsh"

# =============================================================================
# Local overrides (always last)
# =============================================================================

# [Local overrides] User machine-specific final overrides.
source_if_exists "$HOME/.zshrc.local"
