# Helpers shared by the cc* agent scripts in ../bin. They source this file; it isn't a command.
# It lives outside bin/ because install.sh puts everything in bin/ on your PATH.

# where ccp saves plans and cca looks for them: next to the plans from Claude's own plan mode
CC_PLANS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plans"

# cc_plan_slug <plan markdown> [fallback text]: a file/worktree name from the plan's first "# " heading,
# else from the fallback text, else "plan". ccp and cca both use it, so `ccp | cca` names match.
cc_plan_slug() {
  local title slug
  title=$(grep -m1 '^# ' <<<"$1" | cut -c3-) || true
  slug=$(printf '%s' "${title:-${2:-}}" | LC_ALL=C tr '[:upper:]' '[:lower:]' | LC_ALL=C tr -cs 'a-z0-9' '-' | cut -c1-50 | sed 's/^-//; s/-$//')
  printf '%s\n' "${slug:-plan}"
}

# cc_repo_root: the main checkout's root, even from inside a worktree. Fails outside a git repo.
cc_repo_root() {
  local common
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  dirname "$common"
}

# cc_worktree <name>: make .claude/worktrees/<name> on branch worktree-<name> from HEAD (the layout
# `claude -w` uses), adding a timestamp if that name is taken. Prints the new worktree's path.
cc_worktree() {
  local root name=$1
  root=$(cc_repo_root) || { echo "${0##*/}: not in a git repo, so there's no worktree to make" >&2; return 1; }
  if [[ -e "$root/.claude/worktrees/$name" ]] || git show-ref --quiet "refs/heads/worktree-$name"; then
    name="$name-$(date +%s)"
  fi
  git worktree add -q -b "worktree-$name" "$root/.claude/worktrees/$name" HEAD &&
    printf '%s\n' "$root/.claude/worktrees/$name"
}

# cc_agy_flash: the newest Gemini Flash model agy offers, or nothing (agy then uses its default)
cc_agy_flash() {
  agy models 2>/dev/null | grep -oE '^gemini-[0-9.]+-flash-high' | sort -V | tail -1 || true
}

# cc_open_tab <name> <dir> <cmd>: run cmd in <dir> in a new cmux workspace inside cmux, or in a new
# tmux window inside tmux. Only returns when it's in neither, so the caller decides what happens then.
cc_open_tab() {
  if [[ -n "${CMUX_WORKSPACE_ID:-}" ]] && command -v cmux >/dev/null; then
    # own sidebar workspace: cmux notifications, agent status and session restore work per agent
    exec cmux new-workspace --name "$1" --cwd "$2" --focus true --command "$3"
  fi
  if [[ -n "${TMUX:-}" ]]; then
    exec tmux new-window -n "$1" -c "$2" "$3"
  fi
  return 0
}
