# ~/mac-dotfiles/zsh/aliases.zsh -- sourced from .zshrc
# Only aliases, one-liners, and functions that must change this shell (cd / export) live here.
# Anything longer is a script in ../bin (linked into ~/.local/bin by install.sh), so it also
# works from bash, other scripts, tmux/cmux keybindings and agents.

# --- macOS ---
alias flushdns='sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder'
alias o='open .'
alias ql='qlmanage -p &>/dev/null'
alias ip='ipconfig getifaddr en0'
alias pubip='curl -s ifconfig.me && echo'
alias cpwd='pwd | tr -d "\n" | pbcopy'
alias dsclean='fd -H -I "^\.DS_Store$" -x rm'
alias brewup='brew update && brew upgrade && brew cleanup && brew doctor'

# --- dev workflow ---
killport() { lsof -ti tcp:"$1" | xargs -r kill -9; }
port()     { lsof -nP -iTCP:"$1" -sTCP:LISTEN; }
alias listening='lsof -nP -iTCP -sTCP:LISTEN'
alias json='pbpaste | jq .'
alias jsonc='pbpaste | jq -c . | pbcopy'

# --- docker / package managers ---
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f --tail 100'
alias pr='pnpm run'

# --- terminals: cmux is the main one, Ghostty is the lightweight fallback ---
alias ghost='open -na Ghostty --args --working-directory="$PWD"'   # plain Ghostty window in this folder

# --- project switching: cmux workspaces inside cmux, tmux sessions elsewhere ---
alias ts='sessionizer'                           # fzf-pick a project, jump to its workspace/session

# --- tmux: for SSH and the plain-Ghostty fallback. Inside cmux use workspaces/splits instead ---
alias ta='tmux attach 2>/dev/null || tmux new -s main'
alias tl='tmux ls'

# --- claude code (headless / -p; ccf is a script in ../bin) ---
ccmsg()  { git diff --staged | claude -p "write a concise conventional-commit message for this diff, one line under 72 chars, no body unless truly needed"; }
ccpr()   { git diff main...HEAD | claude -p "review this diff for bugs; be terse"; }
ccx()    { claude -p "explain @$1 concisely"; }
ccj()    { claude -p "$1" --output-format json | jq -r '.result'; }

# --- claude code: opsx plan -> review -> apply pipeline, and small tasks ---
# ccplan, ccreview, ccapply, ccdo, ccdoh are scripts in ../bin

# --- claude code: switch which account/config-dir all cc* aliases use (this shell only) ---
ccas() {
  local -a dirs=(~/.claude ~/.ccw ~/.claude-*(N))
  local sel; sel=$(printf '%s\n' "${dirs[@]}" | fzf --print-query --prompt='claude account> ' | tail -1)
  [[ -z "$sel" ]] && return
  [[ "$sel" != /* ]] && sel="$HOME/.claude-$sel"
  if [[ "$sel" == "$HOME/.claude" ]]; then unset CLAUDE_CONFIG_DIR; else export CLAUDE_CONFIG_DIR="$sel"; fi
  echo "claude account: ${CLAUDE_CONFIG_DIR:-default}"
}

# --- branch / worktree create + merge-back (ship, wrm are scripts in ../bin) ---
bc()  { git checkout -b "$1"; }
wc()  { git worktree add "../$1" -b "$1" "${2:-HEAD}" && cd "../$1"; }  # wc <name> [base], base defaults to current HEAD
wcd() { cd "$(git worktree list | fzf --prompt='worktree> ' | awk '{print $1}')"; }

# --- fzf pickers (frg, ff, fbr, fkill, dsh are scripts in ../bin) ---
fcd() { cd "$(fd -t d -d 1 . packages applications 2>/dev/null | fzf)"; }

# --- zsh: global + suffix aliases ---
alias -g G='| grep -i'
alias -s {json,yaml,yml,toml,md,txt}=bat
alias -s {ts,tsx,js,py,go,rs}=cursor
