export EDITOR='code'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export PATH=$ANDROID_SDK_ROOT/cmdline-tools/tools/bin/:$PATH
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools

# export NPM_TOKEN=""

export LOOKIERO_ARCHIVA_USER=m.tuesta
export LOOKIERO_ARCHIVA_PASSWORD=Lookiero2023

export BROWSERSTACK_USERNAME=qdev_PMlfeA
export BROWSERSTACK_ACCESS_KEY=pfsDsoQBNXqroWqXqefb