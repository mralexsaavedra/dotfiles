# ~/.zprofile
# Login/session environment (runs once per login shell).

# Keep PATH deduplicated while building session paths.
typeset -U path PATH

path_add_if_exists() {
  [[ -d "$1" ]] && path=("$1" $path)
}

path_append_if_exists() {
  [[ -d "$1" ]] && path+=("$1")
}

# Session PATH entries
path_add_if_exists "$HOME/.local/bin"
path_add_if_exists "$HOME/.opencode/bin"
path_add_if_exists "$HOME/.cargo/bin"

# Python / pyenv
export PYENV_ROOT="$HOME/.pyenv"
path_add_if_exists "$PYENV_ROOT/bin"

# Bun
export BUN_INSTALL="$HOME/.bun"
path_add_if_exists "$BUN_INSTALL/bin"

# Android SDK
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
path_add_if_exists "$ANDROID_SDK_ROOT/cmdline-tools/tools/bin"
path_append_if_exists "$ANDROID_SDK_ROOT/emulator"
path_append_if_exists "$ANDROID_SDK_ROOT/platform-tools"

# Java
if [[ -x "/usr/libexec/java_home" ]]; then
  JAVA_17_HOME="$(/usr/libexec/java_home -v 17 2>/dev/null)"
  if [[ -n "$JAVA_17_HOME" ]]; then
    export JAVA_HOME="$JAVA_17_HOME"
  elif [[ -d "/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home" ]]; then
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
  fi
fi

# Puppeteer defaults
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD="true"
if command -v chromium >/dev/null 2>&1; then
  export PUPPETEER_EXECUTABLE_PATH="$(command -v chromium)"
fi

# Bun shell integration (kept in login/session to avoid heavy work in .zshenv)
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

export PATH

# Optional machine-specific login overrides
[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
