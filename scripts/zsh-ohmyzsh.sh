source './scripts/utils.sh'

# Zshell : Sets ZSH as a OS X shell

ZShell() {

	# Set ZSH as the OS X shell (better than bash).
	print_success 'Changing to ZSH (shell)'

	chsh -s /bin/zsh
}

ZShell