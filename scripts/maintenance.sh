#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

source "${SCRIPT_DIR}/utils.sh"

if ! command -v brew >/dev/null 2>&1; then
  print_error "Homebrew is not installed. Aborting maintenance."
  exit 1
fi

if ! git -C "${ROOT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  print_error "${ROOT_DIR} is not a git repository. Aborting maintenance."
  exit 1
fi

print_in_purple "\n • Maintenance: Updating system and dotfiles...\n"

# 1. Update Homebrew
print_in_purple "   - Updating Homebrew formulas..."
brew update
brew upgrade

# 2. Update Brewfile
print_in_purple "   - Updating Brewfile..."
brew bundle dump --force --file="${ROOT_DIR}/brew/Brewfile"
# Remove vscode extensions from Brewfile (managed via Settings Sync)
sed -i '' '/^vscode/d' "${ROOT_DIR}/brew/Brewfile"

# 3. Clean up
print_in_purple "   - Cleaning up old versions..."
brew cleanup

# 4. Check for Git changes
if [[ -n "$(git -C "${ROOT_DIR}" status --porcelain)" ]]; then
  print_in_yellow "   [!] Changes detected in dotfiles. Review and push manually.\n"
  git -C "${ROOT_DIR}" status --short
  print_in_purple "   - Suggested next steps:\n"
  print_in_purple "     1) git status\n"
  print_in_purple "     2) git diff\n"
  print_in_purple "     3) git add <files> && git commit && git push\n"
else
  print_success "No changes in dotfiles."
fi

print_success "Maintenance complete!"
