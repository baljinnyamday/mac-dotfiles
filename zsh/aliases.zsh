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

# --- claude code (headless / -p) ---
ccmsg()  { git diff --staged | claude -p "write a concise conventional-commit message for this diff, one line under 72 chars, no body unless truly needed"; }
ccfix()  { uv run pytest "$@" 2>&1 | claude -p "explain why this test is failing and suggest a fix"; }
cclint() { uv run mypy . 2>&1 | claude -p "explain these mypy errors and the smallest fix for each"; }
ccpr()   { git diff main...HEAD | claude -p "review this diff for bugs; be terse"; }
ccx()    { claude -p "explain @$1 concisely"; }
ccj()    { claude -p "$1" --output-format json | jq -r '.result'; }

# --- claude code: opsx plan -> review -> apply pipeline ---
ccplan()   { local m=sonnet; case $1 in -o) m=opus;shift;; -h) m=haiku;shift;; -s) shift;; esac; claude -p "/opsx:propose $*" --permission-mode acceptEdits --model "$m"; }
ccreview() {
  local change; change=$(ls openspec/changes | fzf --prompt="review which proposal? ")
  [[ -n "$change" ]] && bat openspec/changes/"$change"/*.md
}
ccapply()  { local ch=$1; shift; local m=sonnet; case $1 in -o) m=opus;shift;; -h) m=haiku;shift;; -s) shift;; esac; claude -w "$ch" --tmux --model "$m" "/opsx:apply $ch"; }
wcd()      { cd "$(git worktree list | fzf --prompt='worktree> ' | awk '{print $1}')"; }

# --- claude code: small changes, no ceremony ---
ccdo()  { local m=sonnet; case $1 in -o) m=opus;shift;; -h) m=haiku;shift;; -s) shift;; esac; claude -w "quick-$(date +%s)" --tmux --permission-mode auto --model "$m" "$*"; }
ccdoh() { local m=sonnet; case $1 in -o) m=opus;shift;; -h) m=haiku;shift;; -s) shift;; esac; claude -p --permission-mode auto --permission-prompts none --model "$m" "$*"; }

# --- branch / worktree create + merge-back ---
bc()   { git checkout -b "$1"; }
wc()   { git worktree add "../$1" -b "$1" && cd "../$1"; }
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
frg()   { local f; f=$(rg --line-number --no-heading --smart-case "$1" | fzf -d: --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' | cut -d: -f1); [[ -n "$f" ]] && cursor "$f"; }
fbr()   { git checkout "$(git branch --all | grep -v HEAD | sed 's/^[* ]*//;s#remotes/origin/##' | sort -u | fzf)"; }
fkill() { ps aux | sed 1d | fzf -m --header='select process(es) to kill' | awk '{print $2}' | xargs -r kill -9; }
dsh()   { docker exec -it "$(docker ps --format '{{.Names}}' | fzf)" sh; }
ff()    { local f; f=$(fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always {}'); [[ -n "$f" ]] && nvim "$f"; }

# --- zsh: global + suffix aliases ---
alias -g G='| grep -i'
alias -s {json,yaml,yml,toml,md,txt}=bat
alias -s {ts,tsx,js,py,go,rs}=cursor
