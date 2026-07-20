# `CLAUDE.local.md` — per-service manual (example / template)

Every generated KGA integration repo carries a **`CLAUDE.local.md`** at its root. It is the
**unmanaged** companion to the synced base `CLAUDE.md`: the sync (Feature / `make`) never
overwrites it, so this is the safe home for everything specific to the one provider this repo
wraps. The base `CLAUDE.md` points readers here.

Copy the skeleton below into a new repo's `CLAUDE.local.md` and fill it in (the orchestrator's
research step does this automatically when it provisions a repo).

---

```markdown
# CLAUDE.local.md — <Provider> service specifics

Companion to the shared base `CLAUDE.md`. This file is NOT synced — edit it freely; it is the
place for everything specific to wrapping **<Provider>**.

## Provider
- **API:** <Provider name> (<link to reference/ and/or public docs>)
- **URL prefix (our surface):** `/<domain>/<provider>/`  (e.g. `/finance/xero/`)
- **Read / write:** <read-only | read + write>. If write: which write routes, and why.

## Auth model
- <OAuth2 auth-code + offline_access | API key header | HMAC signature | ...>
- **Scopes requested (least-privilege):**
  ```
  <scope-one>
  <scope-two>
  ```
- Token store backend: <file | secret-manager>; rotation behaviour: <...>.

## Module map (deviations from the baseline in CLAUDE.md)
- `app/<provider>/service.py` — <notable methods / pagination / quirks>
- <any provider-specific quirk a contributor must know>

## Reference docs
- Provider docs committed under `reference/` — treat as the primary source; web supplements.

## House-style deviations (if any)
- <state any deviation from the required house style, with the reason>
```
