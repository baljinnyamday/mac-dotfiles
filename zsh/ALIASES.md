# Aliases cheatsheet

Reference for everything in `zsh/aliases.zsh` (and the couple of one-offs in `zsh/.zshrc`). Keep this in sync whenever `aliases.zsh` changes — see the note at the bottom.

## Claude Code: quick headless one-offs

- `cc` — alias for `claude`
- `ccmsg` — drafts a commit message from your staged diff (`git diff --staged` piped in)
- `ccfix <pytest args>` — runs `uv run pytest`, explains why the failure happened and suggests a fix
- `cclint` — runs `uv run mypy .`, explains the errors and the smallest fix for each
- `ccpr` — reviews your branch's diff against `main`, terse bug-focused review
- `ccx <file>` — `claude -p "explain @file concisely"`, quick one-liner explanation
- `ccj "<prompt>"` — runs a prompt, returns just the raw text via `--output-format json | jq -r '.result'`, for piping into scripts
- `ccw` (in `.zshrc`) — runs claude under a separate `~/.ccw` config dir on `claude-fable-5-1`

## Claude Code: big-feature pipeline (plan → review → apply)

- `ccplan "idea" [-o|-s|-h] [-c]` — writes a proposal/design/tasks doc into `openspec/changes/`. No flag = your account's normal default model; `-o`/`-h`/`-s` forces opus/haiku/sonnet; `-c` uses `cursor-agent` (`/opsx-propose`) instead of Claude
- `ccreview` — fzf-pick a proposal, opens its markdown in `bat` to actually read it before trusting it (doesn't call any agent)
- `ccapply <change-name> [-o|-s|-h] [-c]` — implements that change in its own git worktree + tmux pane so you can watch/steer; `-c` runs it via `cursor-agent` in a `tmux new-window` instead (cursor-agent has no built-in tmux flag, so it's wrapped manually)

## Claude Code: small changes, no ceremony

- `ccdo "task" [-o|-s|-h] [-c]` — same idea as `ccapply` but skips the proposal doc: auto-names a throwaway `quick-<timestamp>` worktree, opens its own tmux pane, implements it live
- `ccdoh "task" [-o|-s|-h] [-c]` — headless + backgrounded (`claude --bg`): no worktree, works right on your current branch, returns your terminal immediately. Check on it with `claude logs <id>` / `claude attach <id>` / `claude agents`, or just review with `lg` once it's done

## Claude Code: account switching

- `ccas` — fzf-pick which `CLAUDE_CONFIG_DIR` all `cc*` aliases use (`~/.claude` default, `~/.ccw`, or type a new name to create `~/.claude-<name>`). Only affects the current terminal session — a new tab always starts back on default

## Branch / worktree lifecycle

- `bc <name>` — `git checkout -b <name>`, new branch and switch to it
- `wc <name>` — new worktree + branch in `../<name>`, and cds you into it
- `wcd` — fzf-pick an existing worktree, cd into it
- `ship` — pushes current branch (`-u`) and opens a PR with `gh pr create --fill`
- `wrm` — fzf-pick a worktree, removes it and deletes its local branch (run this after a PR merges)

## fzf pickers, everyday use

- `fcd` — fuzzy-jump into a `packages/*` or `applications/*` folder
- `ff` — fuzzy find a file by name, previews it, opens in `cursor` (your Ctrl+P)
- `frg "<text>"` — fuzzy find text inside files (ripgrep), previews the match in `bat`, opens the pick in `cursor`
- `fbr` — fuzzy-switch git branches
- `fkill` — fuzzy-pick listening port(s)/process(es) (from `lsof`), kills them
- `dsh` — fuzzy-pick a running docker container, shells in (`bash` → `sh` → `docker debug` fallback for shell-less images)

## Everything else already in `aliases.zsh`

- macOS: `flushdns`, `o` (open .), `ql` (quicklook), `ip`, `pubip`, `cpwd` (copy pwd), `dsclean` (delete .DS_Store), `brewup`
- dev workflow: `killport <port>`, `port <port>`, `listening`, `json`/`jsonc` (pbpaste through jq)
- docker/pnpm: `dps`, `dpsa`, `dcu`, `dcd`, `dcl`, `pr` (pnpm run)
- zsh niceties: `G` (global alias for `| grep -i`), suffix aliases opening `json/yaml/yml/toml/md/txt` in `bat` and `ts/tsx/js/py/go/rs` in `cursor`

---

**Keeping this file honest:** whenever `zsh/aliases.zsh` changes, update the matching bullet here in the same commit — don't let this drift into being a stale snapshot of an old design.
