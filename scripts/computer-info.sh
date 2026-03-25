#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/utils.sh"

# set_computer_info : Allows you to set ComputerName, HostName
# and LocalHostName through the keyboard
# (if you have setup this, comment lines 13 to 24)

set_computer_info() {

	print_in_blue "Computer Information\n\n"
	print_question "Computer Name : "
	read -r computer_name
	print_question "Host Name : "
	read -r host_name
	print_question "LocalHostName : "
	read -r local_host_name

	sudo scutil --set ComputerName "$computer_name"
	sudo scutil --set HostName "$host_name"
	sudo scutil --set LocalHostName "$local_host_name"
}

set_computer_info
