# ~/.zshenv
# Variable de entorno se cargan aqui (siempre)

# 1. Configuración Básica
export LANG=en_US.UTF-8
export EDITOR="windsurf --wait"
export VISUAL="windsurf --wait"

# 2. Homebrew Prefix (Optimizado)
if [ -d "/opt/homebrew" ]; then
  export BREW_PREFIX="/opt/homebrew"
else
  export BREW_PREFIX="/usr/local"
fi

# 3. Rust & Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# 4. Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# 5. Puppeteer
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH="$(which chromium 2>/dev/null)"

# 6. Android SDK
export ANDROID_SDK_ROOT="$HOME/Library/Android/sdk"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$PATH"
export PATH="$PATH:$ANDROID_SDK_ROOT/emulator"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"

# 7. Java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"

# 8. AI Assistants (Antigravity & Windsurf)
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.codeium/windsurf/bin:$PATH"
export PATH="$HOME/bin:$PATH"