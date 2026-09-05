#!/usr/bin/env bash
# Symlinks every config in this repo into $HOME. Safe to re-run.
#   ./install.sh          symlink configs
#   ./install.sh --brew   also install everything in the Brewfile
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
  local src="$REPO/$1" dest="$HOME/$2"
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "backed up ~/$2"
  fi
  ln -sfn "$src" "$dest"
  echo "linked    ~/$2"
}

link zsh/.zshrc               .zshrc
link zsh/.zshenv              .zshenv
link git/.gitconfig           .gitconfig
link git/ignore               .config/git/ignore
link aerospace/aerospace.toml .aerospace.toml
link ghostty/config           .config/ghostty/config
link warp/settings.toml       .warp/settings.toml
link starship/starship.toml   .config/starship.toml
link tmux/.tmux.conf          .tmux.conf
link nvim                     .config/nvim
link bin/claude-in            .local/bin/claude-in
link bin/link-agent-docs      .local/bin/link-agent-docs

if [ ! -f "$HOME/.gitconfig.local" ]; then
  printf '[user]\n\tname = Your Name\n\temail = you@example.com\n' > "$HOME/.gitconfig.local"
  echo "created   ~/.gitconfig.local -- put your git identity there"
fi

if [ "${1:-}" = "--brew" ]; then
  brew bundle --file="$REPO/Brewfile"
fi

echo "done."
