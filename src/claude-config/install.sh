#!/bin/sh
# install.sh — runs at IMAGE BUILD time (as root), as its own image layer, BEFORE the
# workspace folder is bind-mounted. So it CANNOT write the config to the workspace root here.
#
# What it does instead:
#   1. installs git + CA certs (needed to fetch the canonical config at container-create)
#   2. stages the shared sync script into the image and puts `sync-claude-config` on PATH
#   3. persists the resolved options (repo/ref) so the postCreate hook can read them
#
# The materialize-into-workspace step happens later: this Feature declares
# `postCreateCommand: sync-claude-config` (devcontainer-feature.json), which runs AFTER the
# workspace bind-mount, from the workspace root, and fetches + writes CLAUDE.md + .claude/.
set -eu

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARE_DIR="/usr/local/share/kga-claude-config"

# 1. Fetch prerequisites (idempotent; tolerate images without apt).
if command -v apt-get >/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends git ca-certificates
  rm -rf /var/lib/apt/lists/*
elif ! command -v git >/dev/null 2>&1; then
  echo "[kga-claude-config] WARNING: git not found and no apt-get; the postCreate sync needs git on PATH" >&2
fi

# 2. Stage the shared sync script (packaged inside this Feature folder) and expose it on PATH.
mkdir -p "$SHARE_DIR"
cp "$FEATURE_DIR/sync-claude-config.sh" "$SHARE_DIR/sync-claude-config.sh"
chmod 0755 "$SHARE_DIR/sync-claude-config.sh"

# 3. Persist resolved option values (all-caps env vars injected by the Feature tooling) so the
#    postCreate wrapper can source them — option env vars are not otherwise exported at create.
CFG_REPO="${CLAUDE_CONFIG_REPO:-https://github.com/KGA-Life/kga-claude-config}"
CFG_REF="${CLAUDE_CONFIG_REF:-main}"
cat > "$SHARE_DIR/config.env" <<EOF
CLAUDE_CONFIG_REPO=$CFG_REPO
CLAUDE_CONFIG_REF=$CFG_REF
EOF

# Install a wrapper that sources the persisted options then runs the shared sync logic.
cat > /usr/local/bin/sync-claude-config <<'EOF'
#!/bin/sh
set -eu
. /usr/local/share/kga-claude-config/config.env
exec /usr/local/share/kga-claude-config/sync-claude-config.sh "$@"
EOF
chmod 0755 /usr/local/bin/sync-claude-config

echo "[kga-claude-config] installed sync-claude-config (repo=$CFG_REPO ref=$CFG_REF); postCreate will materialize config at the workspace root"
