# VSCode (source of truth)

`ides/vscode/` is the canonical editor layer.

- `settings.json` → primary settings for both VSCode and Cursor (unless Cursor has real deltas).
- `keybindings.json` → primary keybindings for both VSCode and Cursor (unless Cursor has real deltas).
- `extensions.txt` → canonical extension baseline.

Workspace override templates (OpenCode canonical):

- `opencode/.config/opencode/templates/workspace-overrides/.vscode/settings.json`
- `opencode/.config/opencode/templates/workspace-overrides/.vscode/opencode-first.instructions.md`
