# ~/.zshrc -- symlinked from ~/mac-dotfiles/zsh/.zshrc
# Machine-specific or secret settings (work package index, tokens) go in
# ~/.zshrc.local, which is sourced at the end and never tracked.

# --- PATH ---
typeset -U path fpath                         # drop duplicate entries
# .zprofile already runs this for login shells; only needed for non-login shells
[[ -z $HOMEBREW_PREFIX && -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="$HOME/.local/bin:$PATH"          # uv, claude, cursor-agent, own scripts
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- Node (nvm) ---
# Sourcing nvm.sh costs ~1s per shell, so put the default Node on PATH directly
# and only load nvm itself the first time `nvm` is run.
export NVM_DIR="$HOME/.nvm"
() {
  local want=""
  [[ -r $NVM_DIR/alias/default ]] && want=$(<$NVM_DIR/alias/default)
  [[ $want == (node|stable|lts/*) ]] && want=""   # "latest" aliases -> newest installed
  local -a bins=($NVM_DIR/versions/node/v${want#v}*/bin(N/nOn))
  (( $#bins )) && path=($bins[1] $path)
}
nvm() {
  unfunction nvm
  . "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}

# --- Completions ---
[ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" $fpath)
# Full compinit scan at most once an hour; otherwise trust the cached dump.
# New tool's completions not showing yet? rm ~/.zcompdump && reload
autoload -Uz compinit
() {
  setopt local_options extended_glob
  local dump=${ZDOTDIR:-$HOME}/.zcompdump
  # compinit leaves an unchanged dump untouched, so touch it or every shell would rescan
  if [[ -n $dump(#qN.mm+60) ]]; then compinit && touch $dump; else compinit -C; fi
}
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# --- Shell tools ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
source <(fzf --zsh)

# --- Editor ---
export EDITOR="cursor --wait"
export VISUAL="$EDITOR"

# Docker Desktop socket (docker-py / testcontainers default to /var/run/docker.sock)
[ -S "$HOME/.docker/run/docker.sock" ] && export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"

# --- Aliases ---
alias ll="eza -l --icons"
alias la="eza -la --icons"
alias lt="eza -la --icons --sort=age"
alias tree="eza --tree --icons"
alias bta="bat"
alias lg="lazygit"
alias gs="git status"
alias gp="git push"
alias python="python3"
alias caff="caffeinate -i"
alias cc="claude"
alias zconfig="cursor ~/.zshrc"
alias reload="source ~/.zshrc"
source "${${(%):-%x}:A:h}/aliases.zsh"   # next to the real .zshrc, wherever the repo is cloned

# Run a command on launch: open --env AUTORUN=claude -na Ghostty --args --working-directory=DIR
[[ -n "$AUTORUN" ]] && { cmd="$AUTORUN"; unset AUTORUN; eval "$cmd"; }

# --- Machine-specific overrides (not tracked) ---
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

ccw() { CLAUDE_CONFIG_DIR="$HOME/.ccw" claude --model claude-fable-5-1 "$@"; }

# Dedupe once more: `export PATH=...` lines bypass typeset -U (.zprofile also adds ~/.local/bin)
path=($path)
