# ~/.zshrc -- symlinked from ~/repos/mac-dotfiles/zsh/.zshrc
# Machine-specific or secret settings (work package index, tokens) go in
# ~/.zshrc.local, which is sourced at the end and never tracked.

# --- PATH ---
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
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
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# --- Completions ---
[ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit && compinit
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
alias ls="eza --icons"
alias ll="eza -l --icons"
alias la="eza -la --icons"
alias lt="eza -la --icons --sort=age"
alias tree="eza --tree --icons"
alias cat="bat"
alias cd="z"
alias lg="lazygit"
alias gs="git status"
alias gp="git push"
alias python="python3"
alias caff="caffeinate -i"
alias zconfig="cursor ~/.zshrc"
alias reload="source ~/.zshrc"

# Run a command on launch: open --env AUTORUN=claude -na Ghostty --args --working-directory=DIR
[[ -n "$AUTORUN" ]] && { cmd="$AUTORUN"; unset AUTORUN; eval "$cmd"; }

# --- Machine-specific overrides (not tracked) ---
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
