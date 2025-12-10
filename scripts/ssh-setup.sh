#!/bin/bash
# ssh-setup.sh: Generates SSH key for Git verification if not present

source './scripts/utils.sh'

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

print_in_purple "\n • Checking SSH Configuration...\n"

if [ ! -f "$SSH_KEY_PATH" ]; then
    print_warning "SSH Key not found at $SSH_KEY_PATH"
    print_question "Do you want to generate a new SSH Key for Git Signing? (y/n) "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        ssh-keygen -t ed25519 -C "git@github.com" -f "$SSH_KEY_PATH" -N ""
        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY_PATH"
        print_success "SSH Key generated!"
        print_in_purple "IMPORTANT: Copy this key to your GitHub Settings -> SSH and GPG Keys:\n"
        cat "$SSH_KEY_PATH.pub"
        echo ""
    else
        print_error "Skipping SSH Key generation. Git commits might fail if signing is enabled."
    fi
else
    print_success "SSH Key already exists."
fi
