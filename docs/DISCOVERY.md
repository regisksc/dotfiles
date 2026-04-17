# Discovery & periodic update

## `./install.sh update`

Scans well-known config locations (allowlist-first) and writes candidates
that are **not yet referenced** by this repo into `state/discovery.txt`.

Scanned roots:

- `~/.config/*` (depth 2)
- `~/.local/share/*` (depth 2)
- Top-level home dotfiles (`~/.*`)

Caches, logs, sockets, and other ephemera are filtered out by name.

## Periodic sync

Scheduler files ship in `schedules/`:

- `schedules/com.dotfiles.sync.plist` — macOS launchd user agent
- `schedules/dotfiles-sync.service` + `.timer` — Linux systemd --user

Both call `./install.sh sync`, which:

1. Refreshes manifests from the current machine
2. Runs a regex secret scan
3. Exits non-zero if anything looks suspicious — meaning the caller
   (you or CI) should investigate before committing.

## Optional: AI-assisted update via Opencode

The idea: trigger an LLM to inspect the repo + `state/discovery.txt`
and propose additions to `manifests/` and overlays.

A suggested prompt (copy into your Opencode/Claude session):

```
You are helping me maintain a public dotfiles repo at ~/Git/dotfiles.

Read:
- PROGRESS.md
- state/discovery.txt
- manifests/
- ai/

Task: propose additions to manifests/ and ai/ for any important software
or config found in discovery.txt that is NOT already represented. Do NOT
include caches, session state, tokens, or anything that could be a secret.
Produce a unified diff I can apply with `git apply`.
```

Keep this as a **workflow**, not a dependency — the repo must remain
usable without any LLM involvement.
