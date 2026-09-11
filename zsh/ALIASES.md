# Aliases cheatsheet

Reference for everything in `zsh/aliases.zsh`, the command scripts in `bin/`, and the couple of one-offs in `zsh/.zshrc`. Keep this in sync whenever they change — see the note at the bottom.

**Where a new command goes:** one-line shortcut → alias in `aliases.zsh`. Needs to `cd` or `export` in your current shell → function in `aliases.zsh` (a script runs in its own process and can't). Anything longer → executable script in `bin/`, then `./install.sh` to link it into `~/.local/bin`. Scripts also work from bash, other scripts, tmux/cmux keybindings and agents.

## Claude Code: quick headless one-offs

- `cc` — alias for `claude`
- `ccmsg` — drafts a commit message from your staged diff (`git diff --staged` piped in)
- `ccf [pytest args]` — runs `uv run pytest` and has Claude fix the failures right in your checkout, then re-run the tests to confirm (does nothing if they already pass). Or pipe in output from anything else: `uv run mypy . |& ccf`, `pnpm build |& ccf` (`|&` also pipes stderr, where most tools print their errors; plain `|` would leave `ccf` with nothing). Headless with `--permission-mode auto`, so you only see Claude's summary at the end; review the changes with `lg`
- `ccpr` — reviews your branch's diff against `main`, terse bug-focused review
- `ccx <file>` — `claude -p "explain @file concisely"`, quick one-liner explanation
- `ccj "<prompt>"` — runs a prompt, returns just the raw text via `--output-format json | jq -r '.result'`, for piping into scripts
- `ccw` (in `.zshrc`) — runs claude under a separate `~/.ccw` config dir on `claude-fable-5-1`

## Claude Code: big-feature pipeline (plan → review → apply)

- `ccplan "idea" [-o|-s|-h] [-c]` — writes a proposal/design/tasks doc into `openspec/changes/`. No flag = your account's normal default model; `-o`/`-h`/`-s` forces opus/haiku/sonnet; `-c` uses `cursor-agent` (`/opsx-propose`) instead of Claude
- `ccreview` — fzf-pick a proposal, opens its markdown in `bat` to actually read it before trusting it (doesn't call any agent)
- `ccapply <change-name> [-o|-s|-h] [-c]` — implements that change in its own git worktree, opened where you can watch/steer: a new cmux workspace (sidebar tab) inside cmux, so each agent gets its own notifications and session restore; a tmux pane elsewhere. `-c` runs `cursor-agent` instead (outside cmux that needs you to be inside tmux, since it uses `tmux new-window`)

**Worktrees from `ccapply` / `ccdo`** are Claude Code's own (`claude -w <name>`), not `wc`'s: they live in `.claude/worktrees/<name>/` (gitignored) on a branch `worktree-<name>`, branched from `origin`'s default branch (not your current branch; set `worktree.baseRef: "head"` in Claude settings to change that). When you exit the session, Claude removes a clean worktree and its branch (a named session asks first), and asks keep/remove if there are changes or new commits. Kept ones show up in `wcd` / `wrm` like any other worktree.

## Claude Code: small changes, no ceremony

- `ccdo "task" [-o|-s|-h] [-c]` — same idea as `ccapply` but skips the proposal doc: auto-names a throwaway `quick-<timestamp>` worktree, opens it in its own cmux workspace (tmux pane outside cmux), implements it live
- `ccdoh "task" [-o|-s|-h] [-c]` — headless + backgrounded (`claude --bg`), returns your terminal immediately. Before editing, Claude moves it into its own worktree under `.claude/worktrees/` (branched from `origin`'s default branch, not your current branch), which Claude's periodic sweep removes after `cleanupPeriodDays` if it holds no uncommitted or unpushed work. `-c` (cursor-agent) runs right in your current checkout instead. Check on it with `claude logs <id>` / `claude attach <id>` / `claude agents`, or just review with `lg` once it's done

## Claude Code: account switching

- `ccas` — fzf-pick which `CLAUDE_CONFIG_DIR` all `cc*` aliases use (`~/.claude` default, `~/.ccw`, or type a new name to create `~/.claude-<name>`). Only affects the current terminal session — a new tab always starts back on default

## Branch / worktree lifecycle

- `bc <name>` — `git checkout -b <name>`, new branch and switch to it
- `wc <name> [base]` — new worktree + branch in `../<name>`, and cds you into it; branches from `base` (e.g. `dev`, `origin/staging`), defaulting to the current branch
- `wcd` — fzf-pick an existing worktree, cd into it
- `ship [gh args]` — pushes current branch (`-u`) and opens a PR with `gh pr create --fill`; extra args go to `gh`, e.g. `ship --base dev`
- `wrm [-f]` — fzf-pick a worktree, removes it and deletes its local branch (run this after a PR merges, from outside the worktree: `wcd` to the main checkout first). Refuses if the worktree has uncommitted/untracked files; keeps the branch if its commits aren't merged or pushed anywhere. `-f` removes anyway and force-deletes the branch (what you want after a squash merge); it lists and asks before throwing away uncommitted files, and a deleted branch comes back with `git branch <name> <sha>` using the sha it prints

## fzf pickers, everyday use

- `fcd` — fuzzy-jump into a `packages/*` or `applications/*` folder
- `ff` — fuzzy find a file by name, previews it, opens in `cursor` (your Ctrl+P)
- `frg "<text>"` — fuzzy find text inside files (ripgrep), previews the match in `bat`, opens the pick in `cursor`
- `fbr` — fuzzy-switch git branches
- `fkill` — fuzzy-pick listening port(s)/process(es) (from `lsof`), kills them
- `dsh` — fuzzy-pick a running docker container, shells in (`bash` → `sh` → `docker debug` fallback for shell-less images)

## Terminals

- `ts [dir]` — fzf-pick a folder (zoxide history + `~/coding/*`) and jump to it. Inside cmux: switches to the workspace already open in that folder, or creates one. Elsewhere: jumps to its tmux session, creating it if needed (same picker as `prefix f` inside tmux)
- `ghost` — opens a plain Ghostty window in the current folder. cmux is the everyday terminal, Ghostty is the fallback when cmux feels laggy (ssh + tmux)
- `cmux .` — opens the current folder as a new cmux sidebar tab (the `cmux` CLI ships with the app)
- `claude-in <folder> [claude args]` — Claude in a new cmux workspace for that folder (new Ghostty window outside cmux)

## tmux (SSH and the Ghostty fallback only)

Don't run a local tmux inside cmux: cmux sees the whole tmux as one terminal, so per-agent notifications, sidebar status and session restore stop working, and you get two sets of keys. cmux workspaces = tmux sessions, cmux splits = panes (keys in the README). Need a process to survive quitting cmux? `cmux local-tmux start <name>` / `attach <name>`. Remote box? `cmux ssh-tmux <host>`.

- `ta` — attach to the last tmux session, or start one called `main`
- `tl` — list tmux sessions

## Everything else already in `aliases.zsh`

- macOS: `flushdns`, `o` (open .), `ql` (quicklook), `ip`, `pubip`, `cpwd` (copy pwd), `dsclean` (delete .DS_Store), `brewup`
- dev workflow: `killport <port>`, `port <port>`, `listening`, `json`/`jsonc` (pbpaste through jq)
- docker/pnpm: `dps`, `dpsa`, `dcu`, `dcd`, `dcl`, `pr` (pnpm run)
- zsh niceties: `G` (global alias for `| grep -i`), suffix aliases opening `json/yaml/yml/toml/md/txt` in `bat` and `ts/tsx/js/py/go/rs` in `cursor`

---

**Keeping this file honest:** whenever `zsh/aliases.zsh` or a command script in `bin/` changes, update the matching bullet here in the same commit — don't let this drift into being a stale snapshot of an old design.
