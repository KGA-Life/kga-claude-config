# Distribution fallback: git submodule (last resort — not the sanctioned path)

The **sanctioned** way to distribute this shared config is the **devcontainer Feature**
(`ghcr.io/kga-life/kga-claude-config/claude-config`) — or, outside a devcontainer,
`make sync-claude-config`. Both materialize `CLAUDE.md` + `.claude/` at the **repo root**,
which is where Claude Code (and human tooling) expect them.

This page documents a git-submodule approach **only as a documented last resort** — e.g. an
environment where neither a devcontainer build nor outbound `curl`/`git clone` of the Feature
is possible. **Do not adopt it by default.** It exists so the fallback is written down, not so
it is used.

## Why the submodule competes with the Feature

- **Wrong location.** A submodule mounts the canonical repo into a **subdirectory** (e.g.
  `./kga-claude-config/`), so `CLAUDE.md` and `.claude/` land **under that subdir**, not at the
  consuming repo's root. Claude Code looks for `CLAUDE.md` + `.claude/` at the **root**; buried
  copies are not picked up. You would still need a copy/symlink step to hoist them to root —
  which is exactly what the Feature / `make` target already does, better.
- **Checkout friction.** Submodule content is absent on a plain `git clone`; consumers must
  remember `git clone --recurse-submodules` (or `git submodule update --init`), and CI must do
  the same. A forgotten flag = missing config, silently.
- **Pinning drift.** A submodule pins a specific commit that must be manually bumped
  (`git submodule update --remote` + commit), so config does **not** propagate on next build the
  way the Feature's `main`-fetch does — it defeats the "live backbone" property (T13).

## Procedure (if you truly must)

```sh
# 1. Add the canonical config as a submodule (buried in a subdir).
git submodule add https://github.com/KGA-Life/kga-claude-config .kga-claude-config

# 2. Hoist the managed files to the repo root (the step the Feature/make does for you).
cp    .kga-claude-config/CLAUDE.md   ./CLAUDE.md
cp -R .kga-claude-config/.claude/.   ./.claude/

# 3. Consumers and CI MUST recurse submodules or the content is absent:
git clone --recurse-submodules <repo>
#   or, after a plain clone:
git submodule update --init

# 4. To pick up a config bump, bump the submodule pointer and re-hoist:
git submodule update --remote .kga-claude-config
cp .kga-claude-config/CLAUDE.md ./CLAUDE.md && cp -R .kga-claude-config/.claude/. ./.claude/
```

**Bottom line:** prefer the Feature (`devcontainer.json` → `ghcr.io/kga-life/kga-claude-config/claude-config:1`)
or `make sync-claude-config`. Reach for the submodule only when neither is available, and treat
the root-vs-subdir hoist + `--recurse-submodules` as the cost you are accepting.
