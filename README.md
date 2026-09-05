# mac-dotfiles

Every config here is symlinked into `$HOME`, so editing a dotfile in place
edits this repo. Commit and push when you're done.

## Fresh Mac

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:baljinnyamday/mac-dotfiles.git ~/repos/mac-dotfiles
cd ~/repos/mac-dotfiles
./install.sh --brew   # symlink configs, then brew bundle
./macos.sh            # key repeat, dock, finder defaults
```

Then fill in `~/.gitconfig.local` (name, email, signing key) and put any
machine-specific env, such as a work package index or tokens, in
`~/.zshrc.local`. Neither file is tracked.

## What's here

| Path | Linked to | Notes |
|---|---|---|
| `zsh/` | `~/.zshrc`, `~/.zshenv` | starship, zoxide, fzf, direnv, nvm, pnpm, bun, uv |
| `git/` | `~/.gitconfig`, `~/.config/git/ignore` | delta pager, zdiff3, identity from `~/.gitconfig.local` |
| `aerospace/` | `~/.aerospace.toml` | i3-style tiling, see keys below |
| `ghostty/` | `~/.config/ghostty/config` | Catppuccin Mocha, JetBrainsMono Nerd Font |
| `starship/` | `~/.config/starship.toml` | gruvbox powerline prompt |
| `tmux/` | `~/.tmux.conf` | |
| `nvim/` | `~/.config/nvim` | |
| `bin/` | `~/.local/bin/` | `claude-in <folder>`, `link-agent-docs [dir]` |
| `Brewfile` | | refresh with `brew bundle dump --force --describe` |
| `macos.sh` | | `defaults write` settings |

## AeroSpace keys

`alt` is the modifier.

| Key | Action |
|---|---|
| alt-enter | new Ghostty window |
| alt-h / j / k / l | focus window (wraps around) |
| alt-shift-h / j / k / l | move window |
| ctrl-alt-h / j / k / l | focus monitor |
| ctrl-alt-shift-h / l | move window to monitor |
| alt-1 … 9, alt-0 | workspace 1 … 9, 0 |
| alt-shift-1 … 0 | move window to workspace |
| alt-tab | previous workspace |
| alt-shift-tab | move workspace to next monitor |
| alt-n / c / s / t / o / w / e | Notion / Claude / Slack / Teams / Outlook / Warp / Cursor workspace, launches the app |
| alt-shift-n / c / s / t / o / w / e | move window to that app's workspace |
| alt-b | open Chrome |
| alt-f | fullscreen |
| alt-shift-space | toggle floating |
| alt-slash, alt-comma | tiles / accordion layout |
| alt-minus, alt-equal | shrink / grow |
| alt-r | resize mode: h/j/k/l, `=` balances, esc |
| alt-shift-q | close window |
| alt-shift-r | reload config |
| alt-shift-; | service mode: r flatten, f float, backspace close others, alt-shift-hjkl join |
