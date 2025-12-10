source './scripts/utils.sh'

# brew_packages : Asks to install packages and software

brew_packages() {

	if cmd_exists "brew"; then

		print_in_blue "Updating brew packages ..."
		execute "brew update"
		execute "brew upgrade"

		print_in_blue "Installing Brewfile"
    ROOT_DIRECTORY="$(dirname "$0")/.."
    BREWFILE="$ROOT_DIRECTORY/brew/Brewfile"
    brew bundle check "--file=$BREWFILE" || brew bundle install "--file=$BREWFILE"

    print_in_blue "Remove outdated versions from the cellar"
		brew cleanup
    brew bundle cleanup --force --file="$BREWFILE"
	else
		print_error 'brew not installed, the packages cannot be installed without brew.'
		./scripts/brew-install.sh
	fi
}

brew_packages