---
name: flutter-init
description: Use when starting a new Flutter project from scratch. Sets up FVM, Riverpod, clean architecture directories, git, and pre-approves all Flutter dev tool permissions so nothing interrupts the session.
version: 0.0.1
---

# Flutter Init

Bootstraps a production-ready Flutter project in one pass. No prompts during the session after this runs.

---

## Step 1 — Permissions

Invoke `update-config` and load the full Flutter dev allow-list from `~/.claude/skills/flutter-app-builder/references/permissions-allow-list.md`. Every Flutter and Dart tool must be pre-approved. No permission popups during the session.

---

## Step 2 — FVM + Project Creation

```bash
fvm install stable
fvm use stable --force
fvm flutter create <app_name> --org com.<yourname> --platforms ios,android
cd <app_name>
```

If FVM is not installed: `brew install fvm` first.

Ask the user for `<app_name>` and `<yourname>` if not provided in the prompt. Default `<app_name>` to `my_app` and `<yourname>` to `dev` if the session is time-critical.

---

## Step 3 — Dependencies

Add to `pubspec.yaml`:

**dependencies:**
```yaml
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.6.1
go_router: ^14.0.0
freezed_annotation: ^2.4.4
json_annotation: ^4.9.0
```

**dev_dependencies:**
```yaml
riverpod_generator: ^2.6.1
build_runner: ^2.4.13
freezed: ^2.5.7
json_serializable: ^6.8.0
mocktail: ^1.0.4
flutter_lints: ^4.0.0
```

Run:
```bash
fvm flutter pub get
```

---

## Step 4 — Gitignore

Add to `.gitignore` (append, do not replace):

```gitignore
# Session artifacts — LLM-targeted, not for repo history
.sessions/

# Secrets
.env
.env.*
*.keystore
*-key.json
google-services.json
GoogleService-Info.plist

# Build symbols
build/symbols/
build/debug-info/
```

---

## Step 5 — Create artifact directories

```bash
mkdir -p .sessions
```

Create `.sessions/INDEX.md` with this initial content:

```markdown
# Session Index

Tracks all artifacts produced during this project's development sessions.
Each row is an artifact that can be referenced by ID for context recovery.

| ID | Timestamp | Type | Slug | Summary | File |
|----|-----------|------|------|---------|------|

## Recovery rules (LLM instructions — do not remove)

| Command pattern | Behaviour |
|-----------------|-----------|
| "execute the latest [type]" | Find last row where Type = [type], load that file, proceed |
| "review/fix [ID]" or "session [ID]" | Load `.sessions/[ID]-*` directly, proceed |
| "fix [finding IDs] from review [ID]" | Load review artifact, act on specified finding rows |
| "recover intent from ~[N] min ago" | Find the row whose Timestamp is closest to `now - N minutes`. **Show the matched row to the user and ask "Is this the artifact you meant? (ID [X] — [slug] — [summary])"**. Wait for confirmation before loading. |

Fuzzy time recovery MUST show the candidate and wait — never auto-load on approximate input.
```

This file is the single entry point for recovering any past context.

---

## Step 6 — Git

```bash
git init
git add .
git commit -m "chore: init project"
```

---

## Done

Confirm to the user:
- Flutter version pinned via FVM
- Riverpod + go_router + Freezed ready
- Permissions pre-approved
- Artifact dirs created and gitignored
- Clean initial commit

**Next skill to invoke:** `/flutter-scope` once you know what you're building.
