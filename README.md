# Alexander Saavedra dotfiles

> Personal dotfiles for a modular macOS dev setup, managed with Stow + Homebrew.

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) to symlink configs into `$HOME` and [Homebrew](https://brew.sh/) as the package source of truth (`brew/Brewfile`).

## ✨ Current Stack

- **Shell**: Zsh + Oh My Zsh.
- **Prompt**: **Powerlevel10k** (`.p10k.zsh`), loaded from `zsh/.zshrc`.
- **Node.js**: **fnm** with automatic version switching (`fnm env --use-on-cd`).
- **Terminal**: Ghostty config included.
- **Navigation/tools**: `zoxide`, `eza`, `bat`, `fzf`, etc.
- **Editors**: VSCode/Cursor/Windsurf sync flow via `scripts/sync-ides.sh`.

## 🚀 Setup

```bash
git clone https://github.com/mralexsaavedra/dotfiles
cd dotfiles
chmod u+x ./setup.sh
./setup.sh
```

`setup.sh` runs macOS defaults + Homebrew bootstrap, then stows the managed folders and syncs IDE configs.

## 🛠 Maintenance (real workflow)

Useful commands:

| Command | Description |
| :--- | :--- |
| `make update` | Runs maintenance + IDE sync (`scripts/maintenance.sh` + `scripts/sync-ides.sh`). |
| `make install` | Installs dependencies from `brew/Brewfile`. |
| `make dump` | Rebuilds `brew/Brewfile` from current brew state (removes vscode lines). |
| `make clean` | Homebrew cleanup. |
| `make sync-ides` | Syncs settings/extensions to VSCode, Cursor and Windsurf. |

> `scripts/maintenance.sh` **does not auto-commit or auto-push**. If changes are detected, it only prints suggested git commands. Review and commit manually.

## 🐚 `zsh/` layout and load order

The shell config is intentionally split by responsibility:

1. **`.zshenv`** → minimal env for *all* zsh instances (locale, editor, `DOTFILES_DIR`, lightweight PATH, secrets hook).
2. **`.zprofile`** → login/session setup (toolchain PATH additions, Java/Android/Python/Bun env).
3. **`.zshrc`** → interactive shell behavior (plugins, history, completions, fnm auto-switch, Powerlevel10k).
4. **`.aliases`** / **`.functions`** → user commands loaded by `.zshrc`.
5. **`*.local` files** (optional, machine-specific) loaded last as overrides.

## 🔒 Local (non-versioned) overrides

Local/secrets files are ignored via `*.local` in `.gitignore`.

- `zsh/.zshenv.local.example` is the template.
- Recommended local files:
  - `~/.zshenv.local` (tokens/secrets)
  - `~/.zprofile.local` (machine login/session overrides)
  - `~/.zshrc.local` (interactive shell overrides)

Prefer keeping shared defaults in tracked files and machine-specific values in `*.local`.

## 📂 Structure (high level)

- `brew/` — Homebrew bundle (`Brewfile`).
- `zsh/` — split shell config and local override templates.
- `scripts/` — setup/maintenance automation.
- `ides/` — shared editor settings/extensions.
- `git/`, `gh/`, `ghostty/`, `vim/`, `raycast/` — tool-specific configs.

## Acknowledgements

Built with ❤️ by Alexander Saavedra.
