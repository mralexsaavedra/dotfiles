source './scripts/utils.sh'

# nvm : Install nvm and node

nvm_install() {
  
  ask_for_confirmation "Would you like to install NVM ?"
  
  if answer_is_yes; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
		print_success 'NVM has been succesfully installed!'

		print_in_blue "install node"
		execute "nvm install node"

		node --version

		npm --version
	else
		print_error 'NVM not installed.'
	fi
}

nvm_install