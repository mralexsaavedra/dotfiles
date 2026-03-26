# IDEs (layered model)

`ides/` is organized in layers to keep OpenCode-first AI policy and editor config maintainable.

## Layers

- `base/` → **canonical shared config** (`settings.json`, `keybindings.json`, `extensions.txt`).
- `editors/{vscode,cursor,windsurf}/` → **real deltas only** (add editor-specific overrides only when needed).
- `ai/copilot/` → editor AI integration layer (Copilot extensions only).
- `ai/antigravity/` → Antigravity package for `~/.agent` (consumes OpenCode via symlinks, no policy duplication).

## Source of truth rules

- Root-level legacy files (`ides/settings.json`, `ides/keybindings.json`, `ides/extensions.txt`) are intentionally removed.
- `scripts/sync-ides.sh` resolves files as:
  1. `ides/editors/<editor>/<file>` if it exists as a **real file** (delta), otherwise
  2. `ides/base/<file>` (canonical default).
- Keep editor layer files absent when there is no real delta.

## OpenCode-first policy

AI policy remains canonical in `opencode/.config/opencode/`.

Editor workspace instruction templates live in:

- `opencode/.config/opencode/templates/workspace-overrides/.vscode/`
- `opencode/.config/opencode/templates/workspace-overrides/.cursor/`
- `opencode/.config/opencode/templates/workspace-overrides/.windsurf/`

`ides/` only references those templates and does not duplicate full rules.

For Antigravity, canonical rules remain in OpenCode and are consumed from `ides/ai/antigravity/.agent/` via symlinks.
