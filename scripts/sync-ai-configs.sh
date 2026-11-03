#!/bin/bash
# Sync AI tool configs from live locations to dotfiles
# Run after gentle-ai or manual edits

set -e

DOTFILES="$HOME/Developer/dotfiles"

echo "Syncing AI configs to dotfiles..."

cp ~/.claude/CLAUDE.md "$DOTFILES/claude-code/.claude/CLAUDE.md"
echo "  ✓ claude-code/.claude/CLAUDE.md"

# Settings shared with the Linux dev LXC (applied there by scripts/linux-setup.sh).
jq '{effortLevel, permissions}' ~/.claude/settings.json > "$DOTFILES/claude-code-settings/settings.shared.json"
echo "  ✓ claude-code-settings/settings.shared.json"

# Skills live in the dotfiles already (~/.claude/skills -> claude-code/.claude/skills).

echo ""
echo "Done. Run 'git -C $DOTFILES diff' to see changes."
