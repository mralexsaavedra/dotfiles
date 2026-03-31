# IDEs (simplified model)

`ides/` is organized with a direct editor layout: VSCode is canonical, Cursor is delta-only.

## Structure

- `vscode/` → **canonical editor config** (`settings.json`, `keybindings.json`, `extensions.txt`).
- `cursor/` → **real deltas only** (add editor-specific overrides only when needed).
- `ai/copilot/` → editor AI integration layer (Copilot extensions only).
- `ai/antigravity/` → Antigravity package for `~/.agent` (consumes OpenCode via symlinks, no policy duplication).

## Source of truth rules

- Root-level legacy files (`ides/settings.json`, `ides/keybindings.json`, `ides/extensions.txt`) remain intentionally removed.
- `scripts/sync-ides.sh` resolves files as:
  1. `ides/vscode/<file>` for canonical defaults.
  2. `ides/cursor/<file>` only when a **real file** exists as Cursor delta.
- Keep Cursor `settings.json` / `keybindings.json` absent when there is no real delta.
- Extensions are layered as: `vscode/extensions.txt` + optional `cursor/extensions.txt` + `ai/copilot/extensions.txt`.

## OpenCode-first policy

AI policy remains canonical in `opencode/.config/opencode/`.

Editor workspace instruction templates live in:

- `opencode/.config/opencode/templates/workspace-overrides/.vscode/`
- `opencode/.config/opencode/templates/workspace-overrides/.cursor/`

`ides/` only references those templates and does not duplicate full rules.

For Antigravity, canonical rules remain in OpenCode and are consumed from `ides/ai/antigravity/.agent/` via symlinks.
