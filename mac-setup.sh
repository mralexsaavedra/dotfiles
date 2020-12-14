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

git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

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

########
# YARN #
########
brew install yarn

# Core casks
brew install --cask alfred
brew install --cask android-studio
brew install --cask appcleaner
# brew install --cask cakebrew
# brew install --cask canon-eos-utility
brew install --cask copyclip
# brew install --cask couleurs
# brew install --cask discord
# brew install --cask dropbox
brew install gh
brew install --cask github
brew install --cask google-chrome
brew install --cask hyper
brew install --cask iterm2
# brew install --cask kap
# brew install --cask keycastr
brew install --cask logitech-options
# brew install --cask mounty
# brew install --cask muzzle
brew install --cask notion
# brew install --cask numi
# brew install --cask qbittorrent
brew install --cask react-native-debugger
brew install --cask rectangle
# brew install --cask responsively
brew install --cask rocket
brew install --cask slack
# brew install --cask skype
brew install --cask spotify
brew install --cask the-unarchiver
brew install --cask visual-studio-code
brew install --cask vlc

brew tap "homebrew/cask-drivers"
brew tap "homebrew/cask-fonts"
brew tap "homebrew/cask-versions"

brew install --cask "font-fira-code"
brew install --cask "font-cascadia-code"

# Remove outdated versions from the cellar.
brew cleanup
