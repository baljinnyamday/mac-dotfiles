#!/usr/bin/env bash
# Copies dotfiles from $HOME into this repo, redacting known sensitive
# values, then commits and pushes. Run this after changing a dotfile locally.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

copy_plain() {
  local src="$HOME/$1" dest="$REPO_DIR/$2"
  [ -e "$src" ] || { echo "skip: $src not found"; return; }
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
}

copy_redacted() {
  local src="$HOME/$1" dest="$REPO_DIR/$2"
  [ -e "$src" ] || { echo "skip: $src not found"; return; }
  mkdir -p "$(dirname "$dest")"
  # Add new sed rules here as you find more machine/company-specific lines.
  sed \
    -e 's|^export UV_EXTRA_INDEX_URL=.*|# export UV_EXTRA_INDEX_URL="https://<your-internal-pypi-index>/simple"|' \
    -e "s#$HOME#\$HOME#g" \
    "$src" > "$dest"
}

copy_gitconfig_redacted() {
  local src="$HOME/.gitconfig" dest="$REPO_DIR/.gitconfig"
  [ -e "$src" ] || { echo "skip: $src not found"; return; }
  # [[:space:]] instead of \s: BSD sed (macOS default) doesn't support \s.
  sed \
    -e 's/^\([[:space:]]*name[[:space:]]*=[[:space:]]*\).*/\1Your Name/' \
    -e 's/^\([[:space:]]*email[[:space:]]*=[[:space:]]*\).*/\1you@example.com/' \
    -e 's/^\([[:space:]]*signingkey[[:space:]]*=[[:space:]]*\).*/\1<your GPG key ID>/' \
    "$src" > "$dest"
}

copy_plain .aerospace.toml .aerospace.toml
copy_plain .skhdrc .skhdrc
copy_plain .yabairc .yabairc
copy_plain .config/starship.toml starship/starship.toml
copy_redacted .zshrc .zshrc
copy_gitconfig_redacted

if git diff --quiet && git diff --staged --quiet; then
  echo "nothing changed."
  exit 0
fi

git add -A
git status --short
read -rp "commit message: " msg
git commit -m "${msg:-Update dotfiles}"
git push origin main
