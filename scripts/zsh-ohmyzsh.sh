source './scripts/utils.sh'

# Zshell : Sets ZSH as a OS X shell and installs Oh-My-ZSH

ZShell() {

	# Set ZSH as the OS X shell (better than bash).
	print_success 'Changing to ZSH (shell)'

	chsh -s /bin/zsh

	directory_backup "$HOME/.oh-my-zsh"

	# Installing Oh-My-ZSH
	cd ~
	curl -L http://install.ohmyz.sh | sh &> /dev/null

	file_exists "$HOME/.zshrc"
	# execute "curl -L -o ~/.oh-my-zsh/custom/themes/materialshell.zsh-theme https://raw.githubusercontent.com/carloscuesta/materialshell/master/materialshell.zsh"

  execute "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

	print_success 'Oh-My-Zsh Installed.'
}

ZShell