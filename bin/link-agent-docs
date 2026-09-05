#!/usr/bin/env bash
# Run inside any project repo to keep CLAUDE.md and AGENTS.md as one file
# instead of two copies that drift apart. Whichever one already exists (or
# is non-empty/newer, if both exist) becomes the real file; the other
# becomes a symlink to it.
set -euo pipefail

DIR="${1:-.}"
cd "$DIR"

CLAUDE="CLAUDE.md"
AGENTS="AGENTS.md"

is_symlink() { [ -L "$1" ]; }

if is_symlink "$CLAUDE" && [ "$(readlink "$CLAUDE")" = "$AGENTS" ]; then
  echo "already linked: $CLAUDE -> $AGENTS"
  exit 0
fi
if is_symlink "$AGENTS" && [ "$(readlink "$AGENTS")" = "$CLAUDE" ]; then
  echo "already linked: $AGENTS -> $CLAUDE"
  exit 0
fi

if [ -f "$CLAUDE" ] && [ ! -f "$AGENTS" ]; then
  SOURCE="$CLAUDE"; LINK="$AGENTS"
elif [ -f "$AGENTS" ] && [ ! -f "$CLAUDE" ]; then
  SOURCE="$AGENTS"; LINK="$CLAUDE"
elif [ -f "$CLAUDE" ] && [ -f "$AGENTS" ]; then
  if [ "$CLAUDE" -nt "$AGENTS" ]; then
    SOURCE="$CLAUDE"; LINK="$AGENTS"
  else
    SOURCE="$AGENTS"; LINK="$CLAUDE"
  fi
  echo "both exist; $SOURCE is newer, treating it as the source of truth."
  echo "backing up $LINK -> $LINK.bak before replacing it with a symlink."
  mv "$LINK" "$LINK.bak"
else
  echo "neither CLAUDE.md nor AGENTS.md exists in $(pwd); nothing to link."
  exit 1
fi

ln -s "$SOURCE" "$LINK"
echo "linked $LINK -> $SOURCE"
