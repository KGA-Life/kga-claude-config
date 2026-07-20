#!/bin/sh
# sync-claude-config.sh — fetch the canonical KGA Claude config and materialize the MANAGED
# files (CLAUDE.md + .claude/) at a destination root, idempotently.
#
# This is the SINGLE source of the sync logic. Two callers use it, so they never diverge:
#   1. the devcontainer Feature (installed onto PATH as `sync-claude-config`, run at postCreate)
#   2. `make sync-claude-config` (CI / non-devcontainer parity)
#
# What it MANAGES (overwrites on every run): CLAUDE.md, .claude/
# What it NEVER touches (per-repo, unmanaged): CLAUDE.local.md, reference/, everything else.
#
# Env / args:
#   CLAUDE_CONFIG_REPO  canonical repo URL   (default: https://github.com/KGA-Life/kga-claude-config)
#   CLAUDE_CONFIG_REF   branch/tag/SHA       (default: main)
#   $1                  destination root     (default: $PWD)
#
# Fetching `main` by default is deliberate: a config bump on the canonical repo propagates on
# the next sync WITHOUT republishing the Feature (the Feature version tracks the sync LOGIC,
# not the config CONTENT). Pin CLAUDE_CONFIG_REF to a tag/SHA for reproducibility.
set -eu

REPO="${CLAUDE_CONFIG_REPO:-https://github.com/KGA-Life/kga-claude-config}"
REF="${CLAUDE_CONFIG_REF:-main}"
DEST="${1:-$PWD}"

if ! command -v git >/dev/null 2>&1; then
  echo "[sync-claude-config] ERROR: git is required but not found on PATH" >&2
  exit 1
fi

# Fetch a shallow copy of the canonical config into a temp dir; always clean it up.
TMP="$(mktemp -d 2>/dev/null || mktemp -d -t kgacfg)"
trap 'rm -rf "$TMP"' EXIT INT TERM

echo "[sync-claude-config] fetching $REPO @ $REF"
git clone --quiet --depth 1 --branch "$REF" "$REPO" "$TMP/src" \
  || { echo "[sync-claude-config] ERROR: clone failed ($REPO @ $REF)" >&2; exit 1; }

if [ ! -f "$TMP/src/CLAUDE.md" ] || [ ! -d "$TMP/src/.claude" ]; then
  echo "[sync-claude-config] ERROR: canonical repo missing CLAUDE.md or .claude/" >&2
  exit 1
fi

mkdir -p "$DEST"

# Materialize the MANAGED files only (idempotent overwrite; extra per-repo files preserved).
cp -f  "$TMP/src/CLAUDE.md" "$DEST/CLAUDE.md"
mkdir -p "$DEST/.claude"
cp -Rf "$TMP/src/.claude/." "$DEST/.claude/"

echo "[sync-claude-config] materialized managed config into $DEST"
ls -la "$DEST/CLAUDE.md" "$DEST/.claude" 2>/dev/null || true
