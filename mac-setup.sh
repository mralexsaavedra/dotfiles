#!/usr/bin/env bash

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

xcode-select --install

########
# BREW #
########
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

# Install GNU core utilities (those that come with OS X are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew install coreutils
sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

#######
# ZSH #
#######
brew install zsh zsh-autosuggestions zsh-syntax-highlighting
chsh -s /bin/zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

##################
# NODE USING NVM #
##################
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm install node

# packages=(
#     fkill-cli
#     serve
#     vtop
# )

# npm install -g "${packages[@]}"

export HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"

# Core casks
brew install --cask android-studio
brew install --cask appcleaner
brew install --cask brave-browser
brew install --cask discord
brew install --cask expo-orbit
brew install --cask firefox
brew install gh
brew install --cask google-chrome
brew install --cask logi-options+
brew install --cask microsoft-edge
brew install --cask openmtp
brew install --cask postman
brew install --cask raycast
brew install --cask raycast
brew install --cask react-native-debugger
brew install --cask runjs
brew install --cask slack
brew install --cask the-unarchiver
brew install --cask transmission
brew install --cask visual-studio-code
brew install --cask vlc
brew install --cask warp
brew install --cask whatsapp

brew tap "homebrew/cask-drivers"
brew tap "homebrew/cask-fonts"
brew tap "homebrew/cask-versions"

brew install --cask "font-fira-code"
brew install --cask "font-cascadia-code"

# Remove outdated versions from the cellar.
brew cleanup
