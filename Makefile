# Makefile — CI / non-devcontainer parity for materializing the shared KGA Claude config.
#
# `make sync-claude-config` fetches the SAME shared sync script the devcontainer Feature uses
# (by raw URL, pinned to CLAUDE_CONFIG_REF) and runs it against this repo's root — so a CI
# runner or a non-devcontainer checkout gets root-level CLAUDE.md + .claude/ without a
# container build, with output identical to the Feature's postCreate step (one script, no
# divergence).
#
# Override the repo/ref if needed:
#   make sync-claude-config CLAUDE_CONFIG_REF=v1.0.0

CLAUDE_CONFIG_REPO ?= https://github.com/KGA-Life/kga-claude-config
CLAUDE_CONFIG_REF  ?= main
SYNC_URL := https://raw.githubusercontent.com/KGA-Life/kga-claude-config/$(CLAUDE_CONFIG_REF)/src/claude-config/sync-claude-config.sh

.PHONY: sync-claude-config
sync-claude-config: ## Materialize root-level CLAUDE.md + .claude/ from the canonical config repo.
	@command -v curl >/dev/null 2>&1 || { echo "make sync-claude-config: curl is required" >&2; exit 1; }
	@command -v git  >/dev/null 2>&1 || { echo "make sync-claude-config: git is required"  >&2; exit 1; }
	@curl -fsSL "$(SYNC_URL)" \
	  | CLAUDE_CONFIG_REPO="$(CLAUDE_CONFIG_REPO)" CLAUDE_CONFIG_REF="$(CLAUDE_CONFIG_REF)" sh -s -- "$(CURDIR)"
