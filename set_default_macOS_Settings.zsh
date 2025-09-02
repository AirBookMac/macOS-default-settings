#!/bin/zsh --no-rcs

# set_default_macOS_Settings.zsh
# Hypoport hub SE -=- Mirko Steinbrecher
# Created on 14.01.2025

# This script sets default settings for Finder, Menubar and Dock.
# Built with the help of plistwatch https://developer.okta.com/blog/2021/07/19/discover-macos-settings-with-plistwatch

# get the currently logged in user
currentUser=$( scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { print $3 }' )
echo "Current user is $currentUser."

# global check if there is a user logged in
if [[ -z "$currentUser" || "$currentUser" == "loginwindow" ]]; then
	echo "No user logged in, cannot proceed"
	exit 1
fi
echo "Current user $currentUser is logged in."

# get the current user's UID
uid=$(id -u "$currentUser")

# convenience function to run a command as the current user
runAsUser() {  
	if [[ "$currentUser" != "loginwindow" ]]; then
		launchctl asuser "$uid" sudo -u "$currentUser" "$@"
	else
		echo "No user logged in"
	fi
}

echo ""
echo "1 is true and 0 is false."
echo ""

# Dock
echo "Do not display recent apps in the Dock"
runAsUser defaults write com.apple.dock "show-recents" -bool false
runAsUser defaults read com.apple.dock "show-recents"

echo "Restart Dock process"
runAsUser killall Dock

# Menubar
echo "Show Battery Percentage in menubar."
runAsUser defaults -currentHost write com.apple.controlcenter.plist BatteryShowPercentage -bool true
runAsUser defaults -currentHost read com.apple.controlcenter.plist BatteryShowPercentage

# Finder
echo "Show path bar in Finder."
runAsUser defaults write com.apple.finder "ShowPathbar" -bool true
runAsUser defaults read com.apple.finder "ShowPathbar"

echo "Show Status Bar."
runAsUser defaults write com.apple.finder "ShowStatusBar" -bool true 
runAsUser defaults read com.apple.finder "ShowStatusBar"

echo "Show Hard Drives on Desktop."
runAsUser defaults write com.apple.finder "ShowHardDrivesOnDesktop" -bool true
runAsUser defaults read com.apple.finder "ShowHardDrivesOnDesktop"

echo "Show Mounted Servers on Desktop."
runAsUser defaults write com.apple.finder "ShowMountedServersOnDesktop" -bool true
runAsUser defaults read com.apple.finder "ShowMountedServersOnDesktop"

echo "Open new Finder Window: Home."
runAsUser defaults write com.apple.finder "NewWindowTarget" -string 'PfHm'
runAsUser defaults read com.apple.finder "NewWindowTarget"

echo "Don't open new Finder windows in tabs."
runAsUser defaults write com.apple.finder "FinderSpawnTab" -bool false
runAsUser defaults read com.apple.finder "FinderSpawnTab"

echo "Sort Folder First."
runAsUser defaults write com.apple.finder "_FXSortFoldersFirst" -bool true 
runAsUser defaults read com.apple.finder "_FXSortFoldersFirst"

echo "Arrange by grid in Finder."
runAsUser /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" "/Users/$currentUser/Library/Preferences/com.apple.finder.plist"

echo "Restart Finder process."
runAsUser killall Finder

exit 0
