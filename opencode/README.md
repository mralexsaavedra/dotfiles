# OpenCode canonical AI package

This package is the **single source of truth** for shared AI policy:

- `~/.config/opencode/AGENTS.md`
- `~/.config/opencode/rules/`
- `~/.config/opencode/skills/`
- `~/.config/opencode/templates/`

Other AI tools in this repo consume this package through real symlinks.

Local override templates are also centralized here (`templates/`) to avoid duplication in consumer packages.
