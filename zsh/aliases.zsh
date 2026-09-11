# ~/mac-dotfiles/zsh/aliases.zsh -- sourced from .zshrc

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

# --- tmux ---
alias ts='tmux-sessionizer'                      # fzf-pick a project, jump to its session
alias ta='tmux attach 2>/dev/null || tmux new -s main'
alias tl='tmux ls'

# --- claude code (headless / -p) ---
ccmsg()  { git diff --staged | claude -p "write a concise conventional-commit message for this diff, one line under 72 chars, no body unless truly needed"; }
ccfix()  { uv run pytest "$@" 2>&1 | claude -p "explain why this test is failing and suggest a fix"; }
cclint() { uv run mypy . 2>&1 | claude -p "explain these mypy errors and the smallest fix for each"; }
ccpr()   { git diff main...HEAD | claude -p "review this diff for bugs; be terse"; }
ccx()    { claude -p "explain @$1 concisely"; }
ccj()    { claude -p "$1" --output-format json | jq -r '.result'; }

# --- claude code: opsx plan -> review -> apply pipeline ---
ccplan()   { if [[ "$1" == -c ]]; then shift; cursor-agent -p --force "/opsx-propose $*"; return; fi; local -a mf=(); case $1 in -o) mf=(--model opus);shift;; -h) mf=(--model haiku);shift;; -s) mf=(--model sonnet);shift;; esac; claude -p "/opsx:propose $*" --permission-mode acceptEdits "${mf[@]}"; }
ccreview() {
  local change; change=$(ls openspec/changes | fzf --prompt="review which proposal? ")
  [[ -n "$change" ]] && bat openspec/changes/"$change"/*.md
}
ccapply()  { local ch=$1; shift; if [[ "$1" == -c ]]; then shift; tmux new-window "cursor-agent -w $ch --force $(printf '%q' "/opsx-apply $ch")"; return; fi; local -a mf=(); case $1 in -o) mf=(--model opus);shift;; -h) mf=(--model haiku);shift;; -s) mf=(--model sonnet);shift;; esac; claude -w "$ch" --tmux "${mf[@]}" "/opsx:apply $ch"; }
wcd()      { cd "$(git worktree list | fzf --prompt='worktree> ' | awk '{print $1}')"; }

# --- claude code: switch which account/config-dir all cc* aliases use (this shell only) ---
ccas() {
  local -a dirs=(~/.claude ~/.ccw ~/.claude-*(N))
  local sel; sel=$(printf '%s\n' "${dirs[@]}" | fzf --print-query --prompt='claude account> ' | tail -1)
  [[ -z "$sel" ]] && return
  [[ "$sel" != /* ]] && sel="$HOME/.claude-$sel"
  if [[ "$sel" == "$HOME/.claude" ]]; then unset CLAUDE_CONFIG_DIR; else export CLAUDE_CONFIG_DIR="$sel"; fi
  echo "claude account: ${CLAUDE_CONFIG_DIR:-default}"
}

# --- claude code: small changes, no ceremony ---
ccdo()  { if [[ "$1" == -c ]]; then shift; tmux new-window "cursor-agent -w quick-$(date +%s) --force $(printf '%q' "$*")"; return; fi; local -a mf=(); case $1 in -o) mf=(--model opus);shift;; -h) mf=(--model haiku);shift;; -s) mf=(--model sonnet);shift;; esac; claude -w "quick-$(date +%s)" --tmux --permission-mode auto "${mf[@]}" "$*"; }
ccdoh() { if [[ "$1" == -c ]]; then shift; cursor-agent -p --force "$*"; return; fi; local -a mf=(); case $1 in -o) mf=(--model opus);shift;; -h) mf=(--model haiku);shift;; -s) mf=(--model sonnet);shift;; esac; claude --bg --permission-mode auto "${mf[@]}" "$*"; }

# --- branch / worktree create + merge-back ---
bc()   { git checkout -b "$1"; }
wc()   { git worktree add "../$1" -b "$1" "${2:-HEAD}" && cd "../$1"; }  # wc <name> [base], base defaults to current HEAD
ship() { git push -u origin HEAD && gh pr create --fill; }
wrm()  {
  local line path branch
  line=$(git worktree list | fzf --prompt='remove which worktree? ')
  path=$(awk '{print $1}' <<< "$line")
  branch=$(awk -F'[][]' '{print $2}' <<< "$line")
  git worktree remove "$path" --force && git branch -d "$branch"
}

# --- fzf pickers ---
fcd()   { cd "$(fd -t d -d 1 . packages applications 2>/dev/null | fzf)"; }
frg()   { local f; f=$(rg --line-number --no-heading --smart-case "$1" | fzf -d: --nth=3.. --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' | cut -d: -f1); [[ -n "$f" ]] && cursor "$f"; }
fbr()   { git checkout "$(git branch --all | grep -v HEAD | sed 's/^[* ]*//;s#remotes/origin/##' | sort -u | fzf)"; }
fkill() { lsof -nP -iTCP -sTCP:LISTEN | sed 1d | fzf -m --header='select port(s)/process(es) to kill' | awk '{print $2}' | sort -u | xargs -r kill -9; }
dsh()   { local c; c=$(docker ps --format '{{.Names}}' | fzf); [[ -n "$c" ]] && (docker exec -it "$c" bash 2>/dev/null || docker exec -it "$c" sh 2>/dev/null || docker debug "$c"); }
ff()    { local f; f=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always {}'); [[ -n "$f" ]] && cursor "$f"; }

# --- zsh: global + suffix aliases ---
alias -g G='| grep -i'
alias -s {json,yaml,yml,toml,md,txt}=bat
alias -s {ts,tsx,js,py,go,rs}=cursor
