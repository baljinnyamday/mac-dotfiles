#!/usr/bin/env bash
# Symlinks safe dotfiles from this repo into $HOME.
# .zshrc / .gitconfig are sanitized templates here (real machine values are
# redacted by push.sh), so they are only copied in when missing -- never
# symlinked, and never overwritten if you already have your own.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$REPO_DIR/$1" dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "backed up existing $dest"
  fi
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}

copy_if_missing() {
  local src="$REPO_DIR/$1" dest="$HOME/$2"
  if [ -e "$dest" ]; then
    echo "skipped $dest (already exists, not overwriting)"
  else
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "created $dest from template -- fill in your real values"
  fi
}

link .aerospace.toml .aerospace.toml
link .skhdrc .skhdrc
link .yabairc .yabairc
link starship/starship.toml .config/starship.toml
link nvim .config/nvim

copy_if_missing .zshrc .zshrc
copy_if_missing .gitconfig .gitconfig

echo "done."
