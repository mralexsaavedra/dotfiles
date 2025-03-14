source './scripts/utils.sh'

# nvm : Install nvm and node

nvm() {
  
  ask_for_confirmation "Would you like to install NVM ?"
  
  if answer_is_yes; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
		if cmd_exists "nvm"; then
			print_success 'NVM has been succesfully installed!'

      print_in_blue "install node"
      execute "nvm install node"
		else
			print_error 'NVM not installed.'
		fi
	else
		print_error 'NVM not installed.'
	fi
}

nvm