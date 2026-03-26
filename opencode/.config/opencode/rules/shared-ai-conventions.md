# Shared AI conventions (OpenCode)

These conventions are defined once in OpenCode and consumed by other tools via symlinks.

## Single source of truth

- Canonical AGENTS: `~/.config/opencode/AGENTS.md`
- Canonical rules: `~/.config/opencode/rules/`
- Canonical skills: `~/.config/opencode/skills/`

## Symlink-first tool model

- `~/.claude/CLAUDE.md` -> OpenCode AGENTS
- `~/.gemini/GEMINI.md` -> OpenCode AGENTS
- `~/.agent/AGENTS.md` -> OpenCode AGENTS
- `~/.agent/rules/shared-ai-conventions.md` -> OpenCode shared conventions

## Operating rules

1. Shared policy changes are edited in OpenCode first.
2. Tool packages keep only tool-local settings/examples.
3. Avoid bridge text duplication when a symlink can express inheritance directly.
