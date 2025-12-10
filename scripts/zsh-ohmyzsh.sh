source './scripts/utils.sh'

# Zshell : Sets ZSH as a OS X shell and installs Oh-My-ZSH

ZShell() {

	# Set ZSH as the OS X shell (better than bash).
	print_success 'Changing to ZSH (shell)'

	chsh -s /bin/zsh

	# Installing Oh-My-ZSH
	cd ~
	curl -L http://install.ohmyz.sh | sh &> /dev/null



	print_success 'Oh-My-Zsh Installed.'
}

ZShell