# Cursor (delta layer)

`ides/cursor/` should contain only real Cursor-specific deltas.

- Keep `settings.json` and `keybindings.json` absent unless Cursor needs explicit overrides.
- `extensions.txt` is optional and only for Cursor-only extensions.

Workspace override template (OpenCode canonical):

- `opencode/.config/opencode/templates/workspace-overrides/.cursor/rules/opencode-first.mdc`
