source './scripts/utils.sh'

# nvm : Install nvm and node

nvm() {
  
  ask_for_confirmation "Would you like to install NVM ?"
  
  if answer_is_yes; then
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh)"
		if cmd_exists "nvm"; then
			print_success 'NVM has been succesfully installed!'

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
      [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

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