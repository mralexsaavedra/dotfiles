# OpenCode consumer contract (symlink-first)

This document replaces text-heavy bridge glue with direct symlink inheritance.

## Contract

1. OpenCode remains canonical for `AGENTS.md`, `rules/`, and shared `skills/`.
2. Claude/Gemini/Antigravity consume canonical files via repository symlinks.
3. Tool-specific local behavior stays in non-versioned `*.local` files.

## Editing policy

- Shared behavior: edit OpenCode canonical files.
- Tool-local examples/settings: edit the corresponding tool package.
- Do not duplicate canonical policy text in consumer files.
