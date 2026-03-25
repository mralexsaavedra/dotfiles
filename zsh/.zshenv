# ~/.zshenv
# Environment variables are loaded here (always)

# 1. Basic Configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR="windsurf --wait"
export VISUAL="windsurf --wait"

# Derive dotfiles path from this file when possible (stow/symlink safe).
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

# 2. Custom Scripts
if [ -n "${DOTFILES_DIR:-}" ]; then
  export PATH="$DOTFILES_DIR/bin:$PATH"
fi


# 3. Homebrew Prefix (Optimized)
if [ -d "/opt/homebrew" ]; then
  export BREW_PREFIX="/opt/homebrew"
else
  export BREW_PREFIX="/usr/local"
fi

# 4. Rust & Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# 5. Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# 6. Puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH="$(which chromium 2>/dev/null)"

# 7. Android SDK
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"
export PATH="$PATH:$ANDROID_SDK_ROOT/emulator"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"

# 8. Java
if command -v /usr/libexec/java_home >/dev/null 2>&1; then
  JAVA_17_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"
  if [ -n "$JAVA_17_HOME" ]; then
    export JAVA_HOME="$JAVA_17_HOME"
  elif [ -d "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" ]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
  fi
fi

# 9. AI Assistants
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# 10 Bun
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# 11. Local Secrets (Tokens, API Keys)
# Loads .zshenv.local if it exists (for tokens like NPM_TOKEN)
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
