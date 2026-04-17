# PROGRESS — LLM Handoff Log

This file is the **single source of truth** for any LLM (or human) taking over
mid-build or mid-deploy. It records what is DONE, IN PROGRESS, and NEXT.
Update it every time you complete a meaningful step.

## How to use this file

1. Read the **Current Phase** section first.
2. Read **Last Completed Step** and **Next Step**.
3. Read **Known Issues / Caveats**.
4. When you finish a step, append an entry to **History** with an ISO
   timestamp, then update **Last Completed Step** / **Next Step**.
5. If you change direction, write a **Decision** entry explaining WHY.

Structured machine-readable progress also lives in `state/progress.jsonl`
(one JSON object per line). Humans edit this file; scripts edit the JSONL.

---

## Current Phase

**Phase:** `build` (repo complete, pre-install)
**Sub-phase:** `backup-complete`
**Target machine:** MacBook-Pro-2 (macOS)
**Mode:** ready for dry-run then install

## Last Completed Step

- Built resilient `lib/preflight.sh` stage: OS detection, tool checks, Xcode CLT/Homebrew bootstrap
- Classified tools as MANDATORY (git, curl, python3, rsync) and OPTIONAL (jq, envsubst)
- Implemented per-tool retry prompts on failure; optional tool failures non-fatal
- Updated `install.sh` to call `preflight` as first step of `cmd_install`
- Updated README with preflight behavior and warning about interactive prompts
- First git commit complete (1865 files, commit 7c9dbc7)

## Next Step

1. Run `./install.sh doctor --verbose` to verify preflight is included in plan.
2. Run `./install.sh install --dry-run` to verify preflight doesn't touch files.
3. Populate `templates/.env.local` with real API keys.
4. Run `./install.sh install` on a fresh VM or secondary account to test end-to-end.
5. Verify all AI environment configs deployed correctly.
6. Update PROGRESS.md with results and mark phase complete.

## Known Issues / Caveats

- No package installation has been performed yet. Nothing on disk has
  been modified outside `~/Git/dotfiles` itself.
- `rollback` can only reverse actions recorded in `state/actions.jsonl`.
  Actions taken before this system existed cannot be rolled back.
- Linux package-manager abstraction supports apt/dnf/pacman best-effort;
  untested distros may need overlay additions.
- Secret scanning is regex-based — not a replacement for a real scanner
  like `gitleaks`. Install one for serious use.

## Decisions

- **2026-04-11**: Chose bash (not zsh) for `install.sh` for portability.
- **2026-04-11**: Chose symlinks (stow-like) over copy for dotfiles so edits
  are reflected live.
- **2026-04-11**: JSONL action log in `state/actions.jsonl` is authoritative
  for rollback; human-readable log in `logs/install-*.log` is for humans.
- **2026-04-11**: `overlays/machine/$(hostname)` layer wins over
  `overlays/{macos,linux}` which wins over `overlays/common`.

## History

| When (UTC)          | Actor    | Step                                    |
|---------------------|----------|-----------------------------------------|
| 2026-04-11T00:00:00 | claude   | Initial scaffold written                |
| 2026-04-11T21:28:00 | claude   | Restructured to flat category layout    |
| 2026-04-12T03:24:00 | claude   | Added cursor, qwen, antigravity; backup complete |
| 2026-04-16T12:00:00 | claude   | Added resilient preflight stage; tool bootstrap |
