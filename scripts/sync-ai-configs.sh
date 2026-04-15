#!/bin/bash
# Sync AI tool configs from live locations to dotfiles
# Run after gentle-ai or manual edits

set -e

DOTFILES="$HOME/Developer/dotfiles"

echo "Syncing AI configs to dotfiles..."

cp ~/.claude/CLAUDE.md "$DOTFILES/claude-code/.claude/CLAUDE.md"
echo "  ✓ claude-code/.claude/CLAUDE.md"

cp ~/.config/opencode/AGENTS.md "$DOTFILES/opencode/.config/opencode/AGENTS.md"
echo "  ✓ opencode/.config/opencode/AGENTS.md"

cp ~/.config/opencode/opencode.json "$DOTFILES/opencode/.config/opencode/opencode.json"
echo "  ✓ opencode/.config/opencode/opencode.json"

cp ~/.gemini/GEMINI.md "$DOTFILES/gemini-cli/.gemini/GEMINI.md"
echo "  ✓ gemini-cli/.gemini/GEMINI.md"

cp ~/.codex/AGENTS.md "$DOTFILES/codex/.codex/AGENTS.md"
echo "  ✓ codex/.codex/AGENTS.md"

echo ""
echo "Done. Run 'git -C $DOTFILES diff' to see changes."
