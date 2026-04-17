# Logging schema

Two log streams are written on every run:

## 1. Human-readable: `logs/install-YYYYMMDD-HHMMSS.log`

```
[2026-04-11T18:03:12Z] [INFO] dotfiles install.sh — mode=install dry_run=false ...
[2026-04-11T18:03:12Z] [INFO] Deploying dotfile symlinks...
```

## 2. Machine-readable: `state/actions.jsonl`

One JSON object per line. Fields:

| field    | meaning                                                 |
|----------|---------------------------------------------------------|
| `ts`     | ISO 8601 UTC timestamp                                  |
| `type`   | `symlink` \| `backup` \| `template` \| `package` \| ... |
| `path`   | target file/path that was touched                       |
| `prev`   | state BEFORE the action                                 |
| `new`    | state AFTER the action                                  |
| `backup` | absolute path to backup (or empty)                      |
| `status` | `ok` \| `fail`                                          |
| `hint`   | shell hint for reversing the action                     |

Example:

```json
{"ts":"2026-04-11T18:03:12Z","type":"symlink","path":"/Users/me/.zshrc","prev":"absent_or_replaced","new":"/Users/me/Git/dotfiles/dotfiles/zsh/.zshrc","backup":"/Users/me/Git/dotfiles/backups/20260411-180312/Users/me/.zshrc","status":"ok","hint":"rm /Users/me/.zshrc && mv /Users/me/Git/dotfiles/backups/20260411-180312/Users/me/.zshrc /Users/me/.zshrc"}
```

## 3. Progress journal: `state/progress.jsonl`

Coarse-grained phase markers used by `PROGRESS.md` readers and LLM handoff.

```json
{"ts":"...","step":"mode:install","status":"start","mode":"install","os":"macos","machine":"foo","dry_run":false,"note":""}
```
