#!/usr/bin/env bash
# macOS defaults. Run once on a new machine; log out and back in for the
# keyboard settings to take effect.
set -euo pipefail

defaults write -g KeyRepeat -int 1
defaults write -g InitialKeyRepeat -int 12
defaults write com.apple.dock autohide -bool true
defaults write com.apple.finder ShowPathbar -bool true

killall Dock Finder
echo "done."
