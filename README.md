# Alexander Saavedra dotfiles

> Alexander Saavedra's personal dotfiles. A robust, modular, and modern configuration for macOS development.

This repository manages all system configurations using [GNU Stow](https://www.gnu.org/software/stow/) for symlinking and [Homebrew](https://brew.sh/) for package management.

## ✨ Features

- **Shell**: [ZSH](https://www.zsh.org/) + [Starship](https://starship.rs/) (Fast, minimal, info-rich prompt).
- **Terminal**: [Ghostty](https://ghostty.org/) configuration with custom themes and performance tweaks.
- **Package Manager**: Homebrew (Brewfile maintained automatically).
- **Node.js**: [FNM](https://github.com/Schniz/fnm) (Fast Node Manager) instead of NVM.
- **Git**: Signed commits (SSH), modern alias (`nuke`, `please`), and Windsurf integration.
- **IDEs**: Unique synchronization system for **VSCode**, **Cursor**, and **Windsurf** (settings & extensions shared).
- **Navigation**: `zoxide` (smart cd), `eza` (better ls), `bat` (better cat).

## 🚀 Setup

The setup process is fully automated. Ideally, run this on a fresh macOS installation.

```bash
git clone https://github.com/mralexsaavedra/dotfiles && cd dotfiles
chmod u+x ./setup.sh
./setup.sh
```

This will:
1. Set macOS defaults (UI, Finder, Dock).
2. Install Homebrew and all packages from `Brewfile`.
3. Configure ZSH, Starship, and CLI tools.
4. Symlink all dotfiles using `stow`.
5. Sync configuration across all IDEs.

## 🛠 Usage & Maintenance

We use a `Makefile` to simplify common tasks:

| Command | Description |
| :--- | :--- |
| `make update` | Update Homebrew, system packages, and **sync IDEs**. |
| `make install` | Install dependencies from `Brewfile`. |
| `make dump` | Save current Brew packages to `Brewfile` (cleans VSCode extensions). |
| `make sync-ides` | Force sync settings/extensions to VSCode, Cursor, and Windsurf. |
| `make clean` | Remove old Brew versions to save space. |

## 📂 Structure

- **`brew/`**: `Brewfile` with all apps and tools.
- **`gh/`**: GitHub CLI config + extensions.
- **`ghostty/`**: Terminal configuration.
- **`git/`**: Global gitconfig, gitignore, and attributes.
- **`ides/`**: Centralized settings for VSCode-based editors.
- **`raycast/`**: Instructions for backup.
- **`scripts/`**: Automation scripts.
- **`starship/`**: Prompt configuration (TOML).
- **`zsh/`**: Shell config (`.zshrc`, `.zshenv`, `.functions`).

## Acknowledgements

Built with ❤️ by Alexander Saavedra.
