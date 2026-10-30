# IDEs (simplified model)

`ides/` is organized with a direct editor layout: VSCode is canonical, Cursor is delta-only.

## Structure

- `vscode/` → **canonical editor config** (`settings.json`, `keybindings.json`, `extensions.txt`).
- `cursor/` → **real deltas only** (add editor-specific overrides only when needed).
- `ai/copilot/` → editor AI integration layer (Copilot extensions only).

## Source of truth rules

- Root-level legacy files (`ides/settings.json`, `ides/keybindings.json`, `ides/extensions.txt`) remain intentionally removed.
- `scripts/sync-ides.sh` resolves files as:
  1. `ides/vscode/<file>` for canonical defaults.
  2. `ides/cursor/<file>` only when a **real file** exists as Cursor delta.
- Keep Cursor `settings.json` / `keybindings.json` absent when there is no real delta.
- Extensions are layered as: `vscode/extensions.txt` + optional `cursor/extensions.txt` + `ai/copilot/extensions.txt`.

## AI policy

AI rules and skills live in the Claude Code package (`claude-code/.claude/`); `ides/` holds editor settings only.
