source './scripts/utils.sh'

# Zshell : Sets ZSH as a OS X shell and installs Oh-My-ZSH

ZShell() {

	# Set ZSH as the OS X shell (better than bash).
	if [ "$SHELL" != "/bin/zsh" ]; then
		print_success 'Changing to ZSH (shell)'
		chsh -s /bin/zsh
	fi

	# Installing Oh-My-ZSH
	if [ ! -d "$HOME/.oh-my-zsh" ]; then
		print_in_purple " • Installing Oh My Zsh..."
		# Run unattended to prevent it from dropping us into a subshell
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		
		# CRITICAL: Remove the .zshrc file created by OMZ installer so stow can link our custom one.
		# If we don't do this, 'stow --adopt' will overwrite our repo config with the default OMZ one.
		rm -f "$HOME/.zshrc"
		
		print_success 'Oh-My-Zsh Installed.'
	else
		print_success 'Oh-My-Zsh is already installed.'
	fi
}

ZShell