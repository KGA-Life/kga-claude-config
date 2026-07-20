#!/bin/bash
# Feature test for `claude-config`, run by `devcontainer features test`.
# Requires the canonical KGA-Life/kga-claude-config repo to be reachable (public) — this is a
# post-publish validation of the fetch+materialize path and its idempotency.
set -e

source dev-container-features-test-lib

TARGET="/tmp/claude-config-test"
rm -rf "$TARGET"; mkdir -p "$TARGET"

check "sync-claude-config on PATH" bash -c "command -v sync-claude-config"
check "materializes root CLAUDE.md" bash -c "sync-claude-config '$TARGET' && test -f '$TARGET/CLAUDE.md'"
check ".claude/ present with settings.json" bash -c "test -d '$TARGET/.claude' && test -f '$TARGET/.claude/settings.json'"
check ".claude/rules present" bash -c "test -f '$TARGET/.claude/rules/python-pep8.md' && test -f '$TARGET/.claude/rules/fastapi-conventions.md'"
check "idempotent re-run (no error, files intact)" bash -c "sync-claude-config '$TARGET' && test -f '$TARGET/CLAUDE.md'"
check "does not clobber an unmanaged CLAUDE.local.md" bash -c "echo local > '$TARGET/CLAUDE.local.md' && sync-claude-config '$TARGET' && grep -q '^local$' '$TARGET/CLAUDE.local.md'"

reportResults
