
# Makefile for Dotfiles management

.PHONY: all setup update install clean help

all: help

# brew/Brewfile on macOS, brew/Brewfile.linux on Linux (homelab dev LXC).
BREWFILE := brew/Brewfile$(if $(filter Linux,$(shell uname -s)),.linux,)

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Run the full setup script (fresh install; on Linux pass ARGS=--machine once per machine)
	./setup.sh $(ARGS)

update: ## Update system, brew, dotfiles and IDEs
	./scripts/maintenance.sh
	./scripts/sync-ides.sh

install: ## Install dependencies from the Brewfile for this OS
	brew bundle --file=$(BREWFILE)

clean: ## Clean up old brew versions and unlisted packages
	brew bundle cleanup --force --file=$(BREWFILE)
	brew cleanup

dump: ## Dump current brew packages to Brewfile
	brew bundle dump --force --file=brew/Brewfile
	sed -i '' '/^vscode/d' brew/Brewfile

reload: ## Reload zsh config
	@echo "⚠️  Make runs in a subshell and cannot reload your current terminal."
	@echo "👉 Please run this command manually: source ~/.zshrc"

sync-ai: ## Sync the Claude Code config (CLAUDE.md) to dotfiles
	./scripts/sync-ai-configs.sh

sync-ides: ## Sync settings and extensions for VSCode and Cursor
	./scripts/sync-ides.sh
