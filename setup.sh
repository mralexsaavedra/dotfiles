# OS X Config File - Alexander Saavedra
# This file handles all my configuration for the OS X system that I'm using like preferences and other stuff.

source './scripts/utils.sh'
execution_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

clear
print_in_purple '\nOS X Config Dotfiles - Alexander Saavedra\n\n'
ask_for_sudo

chmod u+x ./scripts/*.sh

./scripts/computer-info.sh
./scripts/osx-preferences.sh
./scripts/xcode-install.sh
./scripts/brew-install.sh
./scripts/brew-packages.sh
./scripts/zsh-ohmyzsh.sh

stow -t $HOME -v ghostty git zsh starship gh raycast --adopt



./scripts/restart.sh