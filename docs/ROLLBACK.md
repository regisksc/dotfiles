# Rollback

## How it works

`./install.sh rollback` reads `state/actions.jsonl`, walks it in reverse,
and attempts the inverse of each recorded action:

| action type | inverse                                                |
|-------------|--------------------------------------------------------|
| `symlink`   | `rm <path>` then restore `<backup>` if present         |
| `template`  | `rm <path>` (rendered files)                           |
| `backup`    | no-op (backups are preserved until manually removed)   |

## What it cannot undo

- **Package installs.** `brew`, `apt`, `cargo`, `npm -g` installs are
  logged but not automatically removed. Use your package manager's
  own uninstall command or use the `hint` field in each JSONL entry.
- **Edits you made after installation.** If you modified a symlinked
  file in the repo, rollback will remove the symlink but the file in
  the repo retains your edits (which is usually what you want).
- **Actions before this system existed.** Pre-existing state was
  captured in `backups/<ts>/` but only to the extent of files we
  were about to replace.

## LLM handoff for rollback

If you are an LLM asked to roll back this system:

1. Read `PROGRESS.md` to understand the phase.
2. Read `state/actions.jsonl` in reverse (newest first).
3. Prefer running `./install.sh rollback --dry-run` first, then
   `./install.sh rollback` once you've inspected the plan.
4. For non-reversible steps (package installs), use the `hint` field
   in each JSONL entry — it names the exact inverse command.
