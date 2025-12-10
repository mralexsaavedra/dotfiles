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

stow -t $HOME -v ghostty git zsh starship gh --adopt

./scripts/nvm.sh

# GitHub CLI Extensions
if cmd_exists "gh"; then
    print_in_purple "\n • Installing GitHub CLI extensions...\n"
    gh extension install dlvhdr/gh-dash
    gh extension install github/gh-copilot
    gh extension install seachicken/gh-poi
fi

# Sync IDEs (VSCode, Cursor, Windsurf)
./scripts/sync-ides.sh

./scripts/restart.sh