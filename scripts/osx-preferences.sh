source './scripts/utils.sh'

# osxprefs : Setting up my OS X preferences

osxprefs() {
	# Show the ~/Library folder
	chflags nohidden ~/Library
	print_success "Library shown."

	# Scroll direction natural : False
	defaults write -g com.apple.swipescrolldirection -bool false
	print_success "Scroll direction natural (Lion style) set to false."

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true
	print_success "Automatically hide and show the Dock."

	# Display full path in Finder title window
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
	print_success "Finder shows full path in title."

	# Save screenshots in ~/Pictures/Screenshots folder
	mkdir $HOME/Pictures/Screenshots
	defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
	print_success "Screenshot now will appear @ $HOME/Pictures/Screenshots"

	# Check for software updates daily, not just once per week
	defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
	print_success "Software updates checking daily"

	# Trackpad: enable tap to click for this user and for the login screen
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	print_success "Tap to click enabled at the trackpad"

	# Trackpad: map bottom right corner to right-click
	# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
	# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
	# defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
	# defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
	# print_success "Right click mapped to the bottom right corner at the trackpad."

	# Always show scrollbars
	defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
	print_success "Scroll bars set to Automatic behavior"
	# Possible values: `WhenScrolling`, `Automatic` and `Always`

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	print_success "Finder showing filename extensions"

	# Disable the “Are you sure you want to open this application?” dialog
	defaults write com.apple.LaunchServices LSQuarantine -bool false
	print_success "Are you sure you want to open this app dialog disabled."

	# Enable full keyboard access for all controls
	# (e.g. enable Tab in modal dialogs)
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	print_success "Full keyboard acces for all controls enabled."

	# Set the timezone; see `sudo systemsetup -listtimezones` for other values
	sudo systemsetup -settimezone "Europe/Madrid" > /dev/null
	print_success "Time zone set to : Europe/Madrid"

	# Require password immediately after sleep or screen saver begins
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0
	print_success "Password required immediately after sleep or screen saver begins."

	# Enable the Develop menu and the Web Inspector in Safari
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
	print_success "Safari developer tools and web inspector enabled."

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  print_success "Save to disk (not to iCloud) by default enabled."

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  print_success "Keep folders on top when sorting by name enabled."

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  print_success "Search the current folder by default enabled."

  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false
  print_success "Don’t show recent applications in Dock."

	# set keyboard repeat rate to 0, so instant
	defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
	defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
	print_success "Keyboard repeat rate set to 0."

	# instant quick look animation
	defaults write -g QLPanelAnimationDuration -float 0
	print_success "Quick look animation set to 0."

	# increase speed of animation when resizing window of Cocoa apps
	defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
	print_success "Speed of animation when resizing window of Cocoa apps set to 0.001."

	# avoid animation when opening apps from dock
	defaults write com.apple.dock launchanim -bool false
	print_success "Avoid animation when opening apps from dock."

	# bye delay when hiding dock
	defaults write com.apple.Dock autohide-delay -float 0
	print_success "Bye delay when hiding dock."

	# and speed up animation for Dock on hide and show
	defaults write com.apple.dock autohide-time-modifier -float 0.25;killall Dock
	print_success "Speed up animation for Dock on hide and show."

	# speed up animations for Mission Control
	defaults write com.apple.dock expose-animation-duration -float 0.1
	print_success "Speed up animations for Mission Control."

	# maximize window faster
	defaults write -g NSWindowResizeTime -float 0.003
	print_success "Maximize window faster."

  # Wipe all (default) app icons from the Dock
  # This is only really useful when setting up a new Mac, or if you don’t use
  # the Dock to launch apps.
  # defaults write com.apple.dock persistent-apps -array
  # print_success "Wipe all app icons from the Dock."

	# SSD Specific (If you don't have SSD remove that lines.)

	# Remove the sleep image file to save disk space
	# sudo rm /private/var/vm/sleepimage

	# Create a zero-byte file instead…
	# sudo touch /private/var/vm/sleepimage

	# …and make sure it can’t be rewritten
	# sudo chflags uchg /private/var/vm/sleepimage
	# print_success "SSD optimized."

	# Disable the sudden motion sensor as it’s not useful for SSDs
	# sudo pmset -a sms 0
	# print_success "Sudden motion sensor disabled (SSDs not needed)."
}

osxprefs