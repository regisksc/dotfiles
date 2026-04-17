# dotfiles

macOS/Linux workstation recovery system. If you lose access to your machine,
clone this repo on a fresh one and run `./install.sh install` to get back as
close as possible to your full environment.

Safe for a **public** repo: no secrets committed, all sensitive values are
templated via `.env.local` (gitignored). Fully reversible. Instrumented for
LLM-assisted diagnosis and rollback.

---

## If you're starting from a fresh machine

⚠️ **The install process may prompt for input** (e.g., Xcode CLT, sudo password). Do not leave it unattended.

```bash
# 1. Clone the repo
git clone <this-repo> ~/Git/dotfiles
cd ~/Git/dotfiles

# 2. Copy the env template and fill in your keys
cp templates/.env.example .env.local
$EDITOR .env.local

# 3. Preview everything that will happen — no changes made
./install.sh doctor --verbose

# 4. Apply (preflight will install Xcode CLT, Homebrew, and required tools)
./install.sh install
```

**Preflight stage** (automatic):
- Detects OS and package manager
- Installs Xcode CLT (macOS) or required Linux packages
- Installs missing mandatory tools: git, curl, python3, rsync
- Optionally installs jq, envsubst (non-fatal if missing)
- Blocks install if mandatory tools unavailable after retry

---

## Day-to-day: keeping the repo current

Run this whenever you install something new or change AI config:

```bash
./install.sh backup   # capture packages + AI config from machine → repo
./install.sh sync     # backup + secret scan (safe to run before committing)
```

Then commit and push.

---

## Modes

| Mode | What it does |
|---|---|
| `install` | Bootstrap a machine from the repo |
| `doctor` | Dry-run only — validate env, print plan, change nothing |
| `backup` | Capture current machine state → repo (packages, shell, AI) |
| `sync` | `backup` + secret scan — run before committing |
| `update` | Drift discovery — find important software not yet tracked |
| `rollback` | Reverse recorded actions from `state/actions.jsonl` |
| `status` | Show symlink state, managed dirs, progress |

All modes support `--dry-run` (no writes) and `--only CATEGORY` (scope to one category).

---

## Options

```
--dry-run            Plan but do not execute anything
--doctor             Alias for doctor mode
--yes                Skip confirmations
--verbose            Verbose logging
--only CATEGORY      Run only one category (shell, git, ai, agents, …)
--machine-name NAME  Override hostname
--os OS              Override detected OS (macos|linux)
--log-dir DIR        Override log dir (default: ./logs)
--state-dir DIR      Override state dir (default: ./state)
```

---

## What gets captured

### Shell
- `~/.zshrc` → `shell/templates/.zshrc.tmpl` (API keys scrubbed to `${VAR}`)
- `~/.p10k.zsh` → `shell/files/.p10k.zsh` (symlinked)
- Oh My Zsh custom plugins/themes → cloned from `shell/oh-my-zsh-plugins.txt`

### Dev packages
- `packages/manifests/Brewfile` — all Homebrew formulas and casks
- `packages/manifests/npm-global.txt` — global npm packages
- `packages/manifests/pipx.txt` — pipx tools
- `packages/manifests/cargo.txt` — cargo binaries
- `packages/manifests/apt.txt` — Linux apt packages (if applicable)

### AI environment (most important)

| Tool | What's captured | How |
|---|---|---|
| **Claude Code** | skills, hooks, agents, get-shit-done, context-mode, homunculus | symlinks |
| **Claude Code** | settings.json | template (env keys scrubbed) |
| **Opencode** | skills, hooks, rules, CLAUDE.md, AGENTS.md | symlinks |
| **Opencode** | opencode.json, config.json, providers.json, mcp.json | templates |
| **Goose** | skills | symlinks |
| **Goose** | config.yaml, custom_providers | templates |
| **Cursor** | skills, skills-cursor, rules | symlinks |
| **Cursor** | mcp.json, argv.json, cli-config.json | templates |
| **Qwen** | skills, rules, QWEN.md, output-language.md | symlinks/copies |
| **Qwen** | settings.json | template (API keys scrubbed) |
| **Antigravity** | skills, hooks, agents, get-shit-done (in `~/.gemini/antigravity/`) | symlinks |
| **Antigravity** | settings.json, mcp_config.json | templates |
| **Gemini root** | GEMINI.md, skills, settings.json | symlinks + template |

### Agents
- `~/.agents/skills/` → `agents/skills/` (186 skills, symlinked on install)
- `~/.agent-stack/src/` → cloned from `agents/agent-stack-repos.txt` on install

---

## Secrets model

Nothing secret is committed. The flow:

```
templates/.env.example    → copy to .env.local → fill in values
                                    ↓
                          ./install.sh install
                                    ↓
                    render_template() reads .env.local
                    substitutes ${VAR} in *.tmpl files
                    writes rendered output to live locations
```

**Rules:**
- `.env.local` is gitignored — never committed
- All `.tmpl` files use `${UPPER_CASE_VAR}` placeholders only
- `envsubst` is scoped to only those placeholders — won't touch `$schema` or similar
- `./install.sh sync` runs a regex scan before any commit; fails loudly on hits
- Session files, sqlite DBs, and OAuth creds are excluded from backup

See `templates/.env.example` for the full list of variables.

---

## Repository layout

```
install.sh                 Orchestrator — sources all category installers
lib/                       Shared shell modules
  logging.sh               Dual log: human-readable + JSONL action log
  os.sh                    OS/package-manager detection
  backup.sh                Backup-before-replace
  symlink.sh               Conflict-aware symlink deployment
  secrets.sh               Template rendering + secret scan
  doctor.sh                Validation, plan, print
  rollback.sh              Reverse actions from actions.jsonl
  progress.sh              JSONL progress journal (LLM handoff)
  discover.sh              Drift detection

shell/                     Zsh + Oh My Zsh + Powerlevel10k
  files/                   Direct symlink targets (.p10k.zsh)
  templates/               Secret-bearing files (.zshrc.tmpl)
  oh-my-zsh-plugins.txt    Plugins/themes to clone on install

git/                       Git config
tmux/                      Tmux config
nvim/                      Neovim config

packages/                  System packages
  manifests/               Brewfile, apt.txt, npm-global.txt, pipx.txt, cargo.txt

dev/                       Dev toolchain bootstrap (pyenv, fnm, rustup, go)

ai/                        AI environment (one subdir per tool)
  install.sh               Orchestrates all AI tools
  claude/                  Claude Code
  opencode/                Opencode
  goose/                   Goose
  cursor/                  Cursor
  qwen/                    Qwen
  antigravity/             Antigravity / Gemini

agents/                    ~/.agents/skills + ~/.agent-stack repos
  skills/                  186 agent skills
  agent-stack-repos.txt    Git URLs for ~/.agent-stack/src/ repos

templates/                 Shared templates + .env.example
schedules/                 launchd plist + systemd timer for periodic sync

docs/
  DESIGN.md                Architecture, classification model, secrets model
  LOGGING.md               Log/JSONL schema reference
  ROLLBACK.md              Rollback semantics and limits
  DISCOVERY.md             Drift detection and AI-assisted update workflow
  TESTING.md               How to verify dry-run safety and secret leaks

state/                     Runtime state (gitignored)
  actions.jsonl            Authoritative record for rollback
  progress.jsonl           Phase journal for LLM handoff
  symlinks.tsv             Created symlinks

logs/                      Human-readable run logs (gitignored)
backups/                   Timestamped file snapshots (gitignored)
PROGRESS.md                LLM handoff log — read this first if taking over
```

---

## Reversibility

Every file replacement is backed up to `backups/<timestamp>/` before it's touched.
Every action is recorded in `state/actions.jsonl` with a rollback hint.

```bash
./install.sh rollback          # reverse all recorded actions
./install.sh rollback --dry-run  # preview what rollback would do
```

Package installs cannot be automatically reversed — the `hint` field in each
JSONL entry names the exact uninstall command.

---

## LLM handoff

If an LLM is taking over this session:

1. Read `PROGRESS.md` — current phase, last step, next step
2. Read `state/progress.jsonl` — machine-readable phase markers
3. Read `state/actions.jsonl` — every action taken, with rollback hints
4. Run `./install.sh doctor` — validate current state before doing anything

---

## Testing

See `docs/TESTING.md` for:
- Dry-run safety test (mtime comparison before/after)
- Secret leak scan
- Raw key grep
- JSON validity check for all AI tool configs
