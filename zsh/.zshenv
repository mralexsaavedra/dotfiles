# ~/.zshenv
# Environment variables are loaded here (always)

# 1. Basic Configuration
export LANG=en_US.UTF-8
export EDITOR="windsurf --wait"
export VISUAL="windsurf --wait"

# 2. Custom Scripts
export PATH="$HOME/Developer/dotfiles/bin:$PATH"


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
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

# 9. AI Assistants (Antigravity & Windsurf)
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"

# 10. Local Secrets (Tokens, API Keys)
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