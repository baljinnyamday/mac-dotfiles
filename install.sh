#!/usr/bin/env bash
# Symlinks every config in this repo into $HOME. Safe to re-run.
#   ./install.sh          symlink configs
#   ./install.sh --brew   also install everything in the Brewfile
#   ./install.sh --tools  also install CLIs that ship their own installer (claude, uv, cursor-agent)
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BREW=0 TOOLS=0
for arg in "$@"; do
  case "$arg" in
    --brew)  BREW=1 ;;
    --tools) TOOLS=1 ;;
    *) echo "usage: ./install.sh [--brew] [--tools]" >&2; exit 1 ;;
  esac
done

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
link cmux/cmux.json           .config/cmux/cmux.json
link lazygit/config.yml       "Library/Application Support/lazygit/config.yml"
link warp/settings.toml       .warp/settings.toml
link starship/starship.toml   .config/starship.toml
link tmux/.tmux.conf          .tmux.conf
link nvim                     .config/nvim
link bin/claude-in            .local/bin/claude-in
link bin/link-agent-docs      .local/bin/link-agent-docs
link bin/tmux-sessionizer     .local/bin/tmux-sessionizer

if [ ! -f "$HOME/.gitconfig.local" ]; then
  printf '[user]\n\tname = Your Name\n\temail = you@example.com\n' > "$HOME/.gitconfig.local"
  echo "created   ~/.gitconfig.local -- put your git identity there"
fi

if [ "$BREW" = 1 ]; then
  brew bundle --file="$REPO/Brewfile"
fi

# Not in the Brewfile because they self-update through their own installers.
# All of them land in ~/.local/bin, which .zshrc already puts on PATH.
tool() {
  if command -v "$1" >/dev/null || [ -x "$HOME/.local/bin/$1" ]; then
    echo "have      $1"
  else
    echo "installing $1"
    bash -c "$2"
  fi
}

if [ "$TOOLS" = 1 ]; then
  tool claude       'curl -fsSL https://claude.ai/install.sh | bash'
  tool uv           'curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh'
  tool cursor-agent 'curl -fsS https://cursor.com/install | bash'
fi

echo "done."
