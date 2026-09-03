export PATH="$HOME/.local/bin:$PATH"
# export UV_EXTRA_INDEX_URL="https://<your-internal-pypi-index>/simple"
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

alias ls="eza --icons"
alias ll="eza -l --icons"
alias la="eza -la --icons"
alias lt="eza -la --icons --sort=age"
alias tree="eza --tree --icons"
alias cat="bat"
alias find="fd"
alias cd="z"
alias lg="lazygit"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=($HOME/.docker/completions $fpath)
autoload -Uz compinit
(( ${+_comps[docker]} )) || compinit
# End of Docker CLI completions

# Docker Desktop socket (testcontainers/docker-py default to /var/run/docker.sock, which Docker Desktop does not use)
export DOCKER_HOST="unix://$HOME/.docker/run/docker.sock"
