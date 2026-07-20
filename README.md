# kga-claude-config

**The canonical, single source of truth for the shared KGA Life Claude config** — the root
`CLAUDE.md` + `.claude/` tree that every KGA integration-API repo materializes at its root.
Part of the "API Factory" harness ([Linear: Agent Harness for API Builds](https://linear.app/kga-life/project/agent-harness-for-api-builds)).

## What's here

| Path | Role |
|---|---|
| `CLAUDE.md` | The shared **base** operating manual every integration repo gets (managed). |
| `.claude/settings.json` | Shared settings, incl. the `PostToolUse` ruff hook (managed). |
| `.claude/rules/` | `python-pep8.md`, `fastapi-conventions.md` — authoritative style (managed). |
| `src/claude-config/` | The **devcontainer Feature** that distributes the above (+ the shared `sync-claude-config.sh`). |
| `test/claude-config/` | `devcontainer features test` scenarios. |
| `Makefile` | `make sync-claude-config` — CI / non-devcontainer parity (same script as the Feature). |
| `.github/workflows/release.yaml` | Publishes the Feature to GHCR. |
| `docs/` | `submodule-fallback.md` (last-resort path), `claude-local-example.md` (per-service template). |

## How a repo consumes it

**Preferred — devcontainer Feature** (pin by semver tag):

```jsonc
// .devcontainer/devcontainer.json
{
  "features": {
    "ghcr.io/kga-life/kga-claude-config/claude-config:1": {}
  }
}
```

On container create the Feature fetches this repo and materializes `CLAUDE.md` + `.claude/` at
the workspace root. No `postCreateCommand` wiring needed — the Feature self-wires it.

**CI / no devcontainer:** `make sync-claude-config` (fetches the same shared script and runs it).

## Managed vs per-repo (important)

- **Managed** (this repo owns; overwritten on every sync): `CLAUDE.md`, `.claude/`.
- **Per-repo** (a consuming repo owns; the sync NEVER touches): `CLAUDE.local.md` (the
  service-specific manual — see `docs/claude-local-example.md`) and `reference/`.

Change a shared convention **here**, not in a downstream repo — it propagates on the next build.

## A note on enforcement

The `.claude/settings.json` `PostToolUse` hook is a **human-developer / devcontainer**
convenience; it does **not** run inside a managed-agent coding session. For agent-authored
code, **CI is the authoritative enforcement** (`ruff check` / `ruff format --check` / `pytest`),
alongside the three-signal merge gate. `CLAUDE.md` steers agents; the hook does not.

## Versioning

- The **Feature version** (`src/claude-config/devcontainer-feature.json`) tracks the **sync
  logic**, and is what consumers pin (`:1`).
- **Config content** (CLAUDE.md / `.claude/`) is fetched from `main` at build time, so a content
  bump propagates on next build **without** republishing the Feature. Pin `CLAUDE_CONFIG_REF`
  to a tag/SHA for a reproducible content snapshot.
