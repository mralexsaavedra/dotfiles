source './scripts/utils.sh'

# stow : Apply stow

stow() {
  print_in_blue "Executing stow ..."
  execute "stow -t $HOME -v aerospace ghostty git zsh"
}

stow