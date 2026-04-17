# Design

## 1. System overview

A single `install.sh` entrypoint drives a lifecycle-based bootstrap for
macOS and Linux. All behavior is split into small functions inside
`lib/*.sh`. Deployment of dotfiles is symlink-first, with layered
overlays. Every destructive action is backup-first and logged to
`state/actions.jsonl` for later rollback by a human or an LLM.

## 2. Design principles

- **Safe by default.** `doctor` and `--dry-run` change nothing.
- **Backup before replace.** Every replaced file is preserved.
- **Reversible.** JSONL action log is the source of truth for rollback.
- **Public-repo-safe.** Secrets live only in `.env.local`.
- **Idempotent.** Reruns converge, they don't duplicate.
- **LLM-friendly.** `PROGRESS.md` + `state/progress.jsonl` give any
  future agent everything it needs to resume.

## 3. Classification model

| Class      | Example                              | Where               |
|------------|--------------------------------------|---------------------|
| public     | `.zshrc`, `.tmux.conf`, Brewfile     | `dotfiles/` or `manifests/` |
| template   | `.gitconfig.local`, MCP server JSON  | `templates/` `*.tmpl` |
| private    | API keys, SSH private keys           | `.env.local` (never committed) |
| machine    | hostname-specific tweaks             | `overlays/machine/<host>/` |
| ephemeral  | caches, sessions, logs               | ignored entirely    |

## 4. Secrets model

- `.env.local` is gitignored; it is the only place real secrets live.
- Templates use `${VAR}` substitution at render time.
- `./install.sh sync` runs a regex secret scan before committing.
- For production-grade scanning, add `gitleaks` to a pre-commit hook.

## 5. Script lifecycle

```
parse_cli
init_logging
detect_os
acquire_lock
validate_environment
plan_actions
print_plan
→ (doctor/dry-run exits here)
backup_existing_state
install_system_packages
install_dev_toolchains
install_ai_tooling
create_symlinks
apply_machine_overlays
run_post_install_steps
run_health_checks
save_progress_state
print_summary
```

## 6. Overlay precedence

`dotfiles/*` → `overlays/common` → `overlays/<os>` → `overlays/machine/<host>`.
Later layers overwrite earlier ones via the same symlink mechanism.

## 7. Risks and limitations

- Rollback can only undo what the log records. Pre-existing state is
  captured via timestamped backups but cannot be perfectly restored
  if the user edits backed-up files after installation.
- Secret scanning is regex-only; not a replacement for `gitleaks`.
- Linux package-manager support is minimal (apt/dnf/pacman). Untested
  distros may need overlay additions.
- Per-app AI tooling installation is delegated to `ai/*/MANIFEST` files;
  complex apps may need custom post-install steps.

## 8. Next improvements

- Add `gitleaks` pre-commit integration.
- Add `age`/`sops` support for encrypted private overlay.
- Add a `--profile` flag to select named install profiles.
- Wire up launchd / systemd timer for periodic sync.
- Extend `discover.sh` with heuristics per tool class.
