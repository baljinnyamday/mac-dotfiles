# mac-dotfiles

## Usage

- `./install.sh` — symlinks AeroSpace/skhd/yabai/starship/nvim configs from
  this repo into `$HOME`. `.zshrc` and `.gitconfig` in this repo are
  sanitized templates (real secrets redacted), so they're only copied in
  when you don't already have one on the machine — never overwritten.
- `./push.sh` — copies your real dotfiles from `$HOME` back into this repo,
  redacting known machine/company-specific values (internal package index
  URL, git name/email/signing key) along the way, then commits and pushes.
  Run this after you change a dotfile locally.
- `./scripts/link-agent-docs.sh [dir]` — run inside any project repo to
  make `CLAUDE.md` and `AGENTS.md` one file instead of two that drift apart
  (symlinks one to the other, keeping whichever is newer as the source).

## Notes

defaults write -g InitialKeyRepeat -int 12 <br>
defaults write -g KeyRepeat -int 1
```
export ZSH="$HOME/.oh-my-zsh" &&
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH/plugins/zsh-autocomplete &&
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting &&
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/plugins/zsh-syntax-highlighting &&
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH/plugins/zsh-autosuggestions &&
```

```
brew install \
  wget \
  exa \
  git \
  nvm \
  pnpm \
  graphicsmagick \
  commitzen \
  cmatrix \
  vips \
  python

&&

brew install --cask \
  bitwarden \
  google-chrome  \
  firefox \
  brave-browser \
  tor \
  iterm2 \
  visual-studio-code \
  sublime-text \
  docker \
  rectangle \
  slack \
  discord \
  signal \
  vlc \
  calibre \
  figma \
  imageoptim \
  maccy \
  protonvpn \
  zoom \
  skype

```
