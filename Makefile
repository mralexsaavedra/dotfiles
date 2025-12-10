
# Makefile for Dotfiles management

.PHONY: all setup update install clean help

all: help

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Run the full setup script (fresh install)
	./setup.sh

update: ## Update system, brew, dotfiles and IDEs
	./scripts/maintenance.sh
	./scripts/sync-ides.sh

install: ## Install dependencies from Brewfile
	brew bundle --file=brew/Brewfile

clean: ## Clean up old brew versions
	brew cleanup

dump: ## Dump current brew packages to Brewfile
	brew bundle dump --force --file=brew/Brewfile
	sed -i '' '/^vscode/d' brew/Brewfile

reload: ## Reload zsh config
	source ~/.zshrc

sync-ides: ## Sync settings and extensions for VSCode, Cursor, and Windsurf
	./scripts/sync-ides.sh
