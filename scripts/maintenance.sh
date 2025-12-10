#!/bin/bash

source './scripts/utils.sh'

print_in_purple "\n • Maintenance: Updating system and dotfiles...\n"

# 1. Update Homebrew
print_in_purple "   - Updating Homebrew formulas..."
brew update
brew upgrade

# 2. Update Brewfile
print_in_purple "   - Updating Brewfile..."
brew bundle dump --force --file=brew/Brewfile

# 3. Clean up
print_in_purple "   - Cleaning up old versions..."
brew cleanup

# 4. Check for Git changes
if [[ `git status --porcelain` ]]; then
  print_in_purple "   - Changes detected in dotfiles. Committing and pushing..."
  git add .
  git commit -m "chore(maintenance): auto-update system and Brewfile"
  git push origin main
  print_success "Dotfiles updated and pushed!"
else
  print_success "No changes in dotfiles."
fi

print_success "Maintenance complete!"
