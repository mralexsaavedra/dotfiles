# ~/.zshenv
# Global, minimal environment (loaded by every zsh instance).

# 1) Locale + default editors (must be global and consistent)
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# 2) Resolve dotfiles location (stow/symlink safe)
ZSHENV_FILE="${(%):-%x}"
ZSHENV_REAL_FILE="${ZSHENV_FILE:A}"
ZSHENV_CANDIDATE_DOTFILES_DIR="${ZSHENV_REAL_FILE:h:h}"

if [ -z "${DOTFILES_DIR:-}" ]; then
  if [ -d "$ZSHENV_CANDIDATE_DOTFILES_DIR/bin" ]; then
    export DOTFILES_DIR="$ZSHENV_CANDIDATE_DOTFILES_DIR"
  elif [ -d "$HOME/Developer/dotfiles/bin" ]; then
    export DOTFILES_DIR="$HOME/Developer/dotfiles"
  fi
fi

# 3) Minimal cross-shell PATH support for dotfiles scripts
if [ -n "${DOTFILES_DIR:-}" ]; then
  case ":$PATH:" in
    *":$DOTFILES_DIR/bin:"*) ;;
    *) export PATH="$DOTFILES_DIR/bin:$PATH" ;;
  esac
fi

# 4) Lightweight Homebrew prefix hint (used by other zsh files)
if [ -d "/opt/homebrew" ]; then
  export BREW_PREFIX="/opt/homebrew"
elif [ -d "/home/linuxbrew/.linuxbrew" ]; then
  export BREW_PREFIX="/home/linuxbrew/.linuxbrew"
else
  export BREW_PREFIX="/usr/local"
fi

# 5) Local secrets (tokens, API keys)
# Loads .zshenv.local if it exists.
if [ -f "$HOME/.zshenv.local" ]; then
    source "$HOME/.zshenv.local"
else
    # Fallback to looking in the same directory as this file (useful for symlinks)
    # ${(%):-%x} gives the path to the sourced file, :A resolves symlinks, :h gets directory
    ZSHENV_DIR="${${(%):-%x}:A:h}"
    if [ -f "$ZSHENV_DIR/.zshenv.local" ]; then
        source "$ZSHENV_DIR/.zshenv.local"
    fi
fi
