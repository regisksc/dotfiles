---
name: flutter-app-builder
description: This skill should be used when the user asks to "build a Flutter app", "create a Flutter project from scratch", "start a new Flutter app", "bootstrap a Flutter app", "scaffold a Flutter project", "I have a Flutter app idea", or presents an app idea/scope that should be built as a Flutter mobile app for iOS and Android. Also use when asked to "review an ongoing Flutter project", "audit a Flutter codebase", or "continue the Flutter app" (resume sprint loop).
version: 0.0.1
---

# Flutter App Builder

Iterative orchestrator for building production-grade Flutter apps. Runs as a **sprint loop** — each iteration delivers a runnable increment, then stops and asks for direction before continuing.

**Never build everything in one pass. Each sprint must produce something the user can see and validate.**

---

## Mental Model

```
Setup (once) → Sprint 1 → CHECKPOINT → Sprint 2 → CHECKPOINT → ... → Ship
                  ↓                        ↓
           walking skeleton          incremental feature
           (runs on device)          (visible, testable)
```

- **Setup phases run once** (permissions, design, scaffold, architecture)
- **Sprint loop repeats** until user says "ship it"
- **Checkpoints are mandatory** — Claude never starts the next sprint without explicit direction
- **Planning is incremental** — Sprint 1 gets full detail, Sprint 2+ get lightweight plans (200 lines max)

**Never over-plan upfront. Never build everything in one pass. Each sprint must produce something the user can see and validate.**

---

## Fast-Track Mode (Interviews / Demos)

**ONLY triggers when user explicitly says "fast-track", "quick demo", "interview demo", or "build this quickly"**

```
User says: "I need to demo this in an interview" OR "Build this quickly" OR "fast-track this"
```

**Do this instead:**

1. **Skip Setup Phase 1 brainstorming** — ask user for 3 core features verbally, write them as a 10-line bullet list in `BACKLOG.md`
2. **Skip design system search** — use a default dark theme with purple/pink gradient (already in skill)
3. **Sprint 1 only:** Walking skeleton that runs on device in <5 minutes
   - App launches
   - Bottom nav with 2-3 tabs (placeholders)
   - Theme applied
   - FAB visible
4. **No written sprint plan** — just a verbal confirmation: "Sprint 1: navigation shell. OK to proceed?"
5. **Start coding immediately** after confirmation

**Default mode (when user doesn't mention fast-track):** Continue through all sprints automatically without asking for permission at checkpoints. Only stop when:
- All critical/high issues from code reviews are fixed
- App is production-ready (verification passes, no linter errors)
- User explicitly says "stop" or "ship it"

**Fast-Track Backlog template (10 lines max):**
```markdown
# Backlog

## Sprint 1 (now)
- Navigation shell with 3 tabs
- Theme (dark, gradient accent)
- Placeholder screens

## Sprint 2 (next)
- [Feature 1 from user]
- [Feature 2 from user]

## Later
- [Everything else]
```

**Rule:** In fast-track mode, never generate more than 50 lines of planning docs total. Code > documentation.

---

## Cross-Cutting Concerns (active throughout)

**Context management:**
- All `flutter test`, `flutter analyze`, large output → `ctx_execute_file` / `ctx_batch_execute`
- Trigger `gsd:pause-work` + `context-handoff` when context >70% OR at any checkpoint
- RTK rewrites commands transparently when installed

**Security** — woven in at every sprint, never bolted on at the end:
- In every sprint containing auth, storage, or input-handling features: consult `references/tdd-patterns.md` (Security-Relevant Test Cases) and `references/security-patterns.md` (Phase 4 section) and write those security tests as part of the sprint's TDD cycle — not as a final gate
- Reference: `references/security-patterns.md`

**SOLID compliance** — structural requirement enforced from architecture phase:
- ISP: one abstract interface per capability in `domain/datasources/`
- DIP: `presentation/` never imports `data/`; domain defines interfaces, data implements them
- NO REPOSITORY LAYER: Use cases call datasources directly (unless complex aggregation needed)
- Reference: `references/clean-architecture-solid.md`

**Performance** — enforced from Sprint 1, not bolted on at the end:

- **No widget-returning methods.** Never write `Widget _buildFoo()` as a method on a widget class. Extract a dedicated `StatelessWidget` instead. Widget methods bypass Flutter's element reconciliation and rebuild more than necessary.
  ```dart
  // WRONG
  Widget _buildHeader() => Text('Hello');

  // CORRECT
  class _Header extends StatelessWidget {
    const _Header();
    @override
    Widget build(BuildContext context) => const Text('Hello');
  }
  ```
- **Lazy builders for lists and grids.** Always use `ListView.builder`, `GridView.builder`, `SliverList.builder`, etc. for any list of unknown or potentially large length. Never use `ListView(children: items.map(...).toList())` unless the list is provably small and static.
- **`const` everywhere.** Annotate every widget instantiation that can be `const`. Mark leaf widgets and their constructors `const`. This lets Flutter skip subtree rebuilds entirely.
- **`RepaintBoundary` for expensive subtrees.** Wrap independently animated or frequently updating subtrees (e.g., a live chart, a video preview) in `RepaintBoundary` to isolate rasterization.
- **Isolates for heavy computation.** Move CPU-intensive work (JSON parsing of large payloads, image processing, encryption, heavy sorting) off the main isolate using `compute()` or `Isolate.run()`. The UI thread must stay free.
  ```dart
  final result = await compute(_parseHeavyJson, rawJson);
  ```
- **Avoid rebuilding large subtrees.** Use `BlocSelector` / `select` / `context.select` to subscribe only to the slice of state a widget actually uses, rather than the entire bloc/provider state.
- **`AutomaticKeepAliveClientMixin` and `keepAlive`** for pages in a `PageView` or `TabBarView` that are expensive to rebuild on re-entry.
- **Image optimization.** Always specify `width`/`height` on `Image` widgets and use `cacheWidth`/`cacheHeight` to decode at display size. Prefer `cached_network_image` for network images.
- **Avoid `Opacity` widget for animations.** Prefer `FadeTransition` (uses the render layer, avoids offscreen compositing) over `Opacity` when animating transparency.

These are not optional polish — they are structural constraints. Flag violations during code review the same way SOLID violations are flagged.

---

## One-Time Setup

### Setup Phase 0 — Permissions Bootstrap + Git Init

**Skills:** `update-config`

1. Invoke `update-config` with the full Flutter dev allow list from `references/permissions-allow-list.md`
2. `git init`
3. Create `.gitignore` with Flutter standard entries **plus** these mandatory additions:
   ```gitignore
   # Secrets
   .env
   .env.*
   *.keystore
   *-key.json
   google-services.json
   GoogleService-Info.plist
   build/symbols/
   build/debug-info/

   # AI planning docs — LLM-targeted, not for repo history
   .planning/
   docs/superpowers/
   sprints/
   design-system/
   BACKLOG.md
   ```
4. `git commit -m "chore: init project"`

**Rule:** Never commit files matching `.planning/**`, `docs/superpowers/**`, `sprints/**`, `design-system/**`, or `BACKLOG.md`. These are AI orchestration artifacts, not product code.

---

### Setup Phase 1 — Brainstorm & Design System

**Skills:** `superpowers:brainstorming`, `flutter-ui-design`

**CRITICAL: This phase must complete in under 2 minutes. Brevity is mandatory.**

1. Invoke `superpowers:brainstorming` with explicit constraints:
   - App purpose (1 sentence)
   - Target audience (1 sentence)
   - Core features: bullet list only, no acceptance criteria
   - Sprint assignment: Sprint 1 / Sprint 2 / Later (tag only)
   - State management: **BLoC** (default) or Riverpod
   - **HARD LIMIT:** 200 lines max for the backlog. No file paths, no implementation details.

2. Run design system search:
   ```bash
   python3 ~/.claude/skills/flutter-ui-design/scripts/search.py "<app keywords>" --design-system --persist -p "AppName"
   ```
   - **Constraint:** Only capture color palette, typography scale, and 2-3 key component styles
   - Skip exhaustive component catalog for now — add details later if needed

3. `design-system/MASTER.md` is the design reference (not a spec document)

**Output:** ~200 line backlog + minimal design system

**Rules:**
- Never write detailed feature specs upfront. Only Sprint 1 gets detailed planning.
- Never include file paths, method signatures, or implementation details in the backlog.
- If the brainstorming skill produces verbose output, truncate it and move on.
- Later sprints are planned just-in-time during their sprint, not here.

**Timebox:** The entire Setup Phase 1 (backlog + design system) should not exceed 500 lines and must complete in under 2 minutes. If it's taking longer, cut scope and move to scaffolding.

---

### Setup Phase 2 — Project Scaffold (FVM + 3 Flavors)

**Fast-track: Skip to 1 flavor (dev only) if time-critical.**

See `references/fvm-flavors-setup.md` for all commands and file contents.

1. Install and pin Flutter version via FVM
2. `fvm flutter create` with correct org and package name
3. Create entry points:
   - **Full:** `lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`
   - **Fast-track:** Just `lib/main.dart` (skip flavors)
4. **Android**: Configure `productFlavors` in `android/app/build.gradle` (section 4 of reference)
   - **Fast-track:** Skip flavors, use default build config only
5. **iOS**: Create xcconfig files under `ios/Flutter/` (section 5a)
   - **Fast-track:** Skip — notify user this is a manual step for later
6. **VSCode**: Write `.vscode/launch.json` with configurations (section 7)
   - **Fast-track:** Single config for dev only
7. **Android Studio**: Write `.idea/runConfigurations/*.xml` for all 3 flavors (section 9)
   - **Fast-track:** Skip — VSCode config is enough for demo
8. **Environment template**: Create `.env.example` with common environment variable placeholders (section 8)
9. Wire `--obfuscate --split-debug-info` into prod build commands
   - **Fast-track:** Skip — only needed for release builds
10. `git commit -m "chore: scaffold project"`

**`.env.example` template** — create this file with generic, provider-agnostic placeholders:

```bash
# API Configuration
API_BASE_URL=https://api.example.com
API_TIMEOUT_MS=30000

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true

# Push Notifications (provider-agnostic)
PUSH_NOTIFICATIONS_ENABLED=false
PUSH_SERVER_KEY=your_push_server_key_here

# Authentication
AUTH_TOKEN_EXPIRY_SECONDS=3600
REFRESH_TOKEN_ENABLED=true

# Rate Limiting
RATE_LIMIT_REQUESTS_PER_MINUTE=60

# Logging
LOG_LEVEL=debug
LOG_ENABLE_NETWORK_INSPECTOR=false

# Build Metadata
APP_VERSION=1.0.0
BUILD_NUMBER=1
```

**Rule:** Never commit `.env` or `.env.*` files — only `.env.example` goes in version control. Each developer copies `.env.example` to `.env` locally and fills in their own values.

**Fast-track timebox:** Setup Phase 2 should take <3 minutes. If it's taking longer, skip flavors and IDE configs — just create the project and get to coding.

---

### Setup Phase 3 — Architecture Skeleton

**Skills:** `gsd:plan-phase`, `coding-standards`

**Fast-track: Combine with Sprint 1 — create directories as you code, not upfront.**

Create the empty layer structure — **no feature code yet**:

```
lib/src/
  domain/
    entities/        ← pure Dart, zero Flutter imports
    datasources/     ← abstract interfaces only (ISP) - what data ops needed
    usecases/        ← abstract interfaces only - business operation contracts
    errors/          ← sealed error hierarchy
  data/
    adapters/        ← concrete implementations of datasources
    models/          ← extend domain entities via inheritance
    usecases/        ← concrete implementations with business logic
  presentation/
    viewmodels/      ← BLoC cubits or Riverpod providers
    screens/
    widgets/
  di/                ← dependency injection (get_it or manual)
```

**Architecture Pattern: Use Case → Datasource (NO Repository Layer)**

- Domain defines WHAT operations are needed (datasource interfaces)
- Data implements HOW they work (concrete use cases + adapters)
- Use cases contain BUSINESS LOGIC (validation, transformation, etc.)
- NO repository layer unless complex data aggregation from multiple sources

`git commit -m "chore: set up clean architecture skeleton"`

**Fast-track:** Skip the empty skeleton commit. Create directories as part of Sprint 1 coding.

---

## Sprint Loop (repeat until ship)

**Every sprint follows the same 4-step structure. Do not skip steps. Do not run more than one sprint without a checkpoint.**

### Step 1 — Sprint Planning

**Skills:** `superpowers:writing-plans`, `gsd:plan-phase`

**Precondition check (run before anything else):**
- Does `BACKLOG.md` exist? If not → setup has not been run → execute Setup Phases 0-3 before proceeding
- Does `design-system/MASTER.md` exist? If not → run Setup Phase 1 (brainstorm + design system) before proceeding
- If resuming a previous session: read `BACKLOG.md` to identify current sprint, read `sprints/sprint-[N]-plan.md`, run `flutter test` + `flutter analyze`, present the Sprint Summary (Step 4a format) for the last completed sprint, then ask for direction before planning the next sprint

**Planning depth is proportional to sprint number:**
- **Sprint 1:** Detailed plan (walking skeleton must be fully specified)
- **Sprint 2+:** Lightweight plan — only what's needed for this sprint, not the whole app

**Fast-track mode (interviews/demos):**
- Skip written plans entirely
- Verbal confirmation only: "Sprint 1: navigation shell with 3 tabs, theme, FAB. OK?"
- Write the 10-line backlog and start coding

Before writing any code:

1. Show the current backlog (or create it on Sprint 1) and update it to reflect the current sprint scope
2. Identify what will be built this sprint:
   - Sprint 1 **must** be the walking skeleton: app launches, navigation shell works, placeholder screens visible on device
   - Sprint N: pick the next highest-priority unbuilt features — aim for 1-3 features per sprint
3. Invoke `superpowers:writing-plans` to produce a written sprint plan:
   - **Sprint 1 plan:** Full detail (goal, features with acceptance criteria, technical approach, risks)
   - **Sprint 2+ plan:** Lightweight — goal, features in scope (bullet points only), technical notes for known complexities
   - **Timebox:** Sprint 2+ plans should not exceed 200 lines. Do not over-specify.
   - **Fast-track:** Skip written plan, confirm verbally and start coding
4. Save the plan to `sprints/sprint-[N]-plan.md`
   - **Fast-track:** Skip — just update `BACKLOG.md` with sprint assignment
5. Present a summary and ask: **"Does this sprint plan look right to you?"** — wait for confirmation before proceeding to Step 2
   - Only an explicit yes ("yes", "looks good", "proceed", "go ahead") counts as confirmation
   - Any other response — questions, partial feedback, "mostly yes but..." — is treated as a change request: revise the plan and ask again

**Rule:** Never write detailed specs for future sprints. Plan only what you're about to build. Details emerge as you build.

**Timebox:** Sprint 1 planning should take <2 minutes. Sprint 2+ planning should take <1 minute. If it's taking longer, you're over-specifying — cut the detail and start coding.

---

### Step 2 — TDD Implementation

**Skills:** `tdd`, `tdd-workflow`, `superpowers:test-driven-development`, `superpowers:executing-plans`

Invoke `superpowers:executing-plans` to drive execution against the written sprint plan. Invoke `tdd` or `tdd-workflow` at the start of each feature within the sprint.

**Atomic commit strategy per feature:**
1. Write tests → `flutter test` must **RED** → `git commit -m "test(scope): add <Feature> failing tests"`
2. Write minimum implementation → `flutter test` must **GREEN** → `git commit -m "feat(scope): implement <Feature>"`
3. Optional refactor → `git commit -m "refactor(scope): clean up <Feature>"`

Only implement what is in the current sprint scope. If a dependency on a future feature is discovered, add it to the backlog — do not implement it now.

---

### Step 3 — Sprint Verification

**Skills:** `verification-loop`, `superpowers:verification-before-completion`

Run before every checkpoint — no exceptions:

```bash
flutter test                             # all tests pass
flutter analyze                          # zero errors
flutter format --set-exit-if-changed .   # formatting clean
flutter run -d <device> --flavor dev     # app runs on device (Sprint 1+)
```

Fix any failures before proceeding to checkpoint.

---

### Step 4 — Checkpoint (MANDATORY)

**This step is non-negotiable. Claude must stop here after every sprint.**

#### 4a — Sprint Summary

Present this structured summary:

```
--- Sprint [N] Complete ---

What was built:
- [feature 1] — [one line description]
- [feature 2] — [one line description]

What you can verify now:
- [specific thing user can see/tap/test on device]

Tests: [X passing / 0 failing]
Analyze: [clean / N warnings]

Remaining backlog:
- [feature A] ← suggested for Sprint N+1
- [feature B]
- [feature C]

--- Sprint [N+1] Starting ---
Goal: [one sentence]
Features: [bullet list]
```

**Default behavior:** Automatically proceed to Sprint N+1 unless user says "stop", "hold on", or gives corrective feedback.

**Only pause and wait for user response when:**
- User explicitly requests a pause
- Corrective feedback is given (use Correction Protocol 4b)
- Context window reaches 70%
- All critical/high issues are fixed and app is ready for final validation

#### 4b — Correction Protocol (when user gives corrective feedback)

When the user says anything that indicates a correction — wrong direction, wrong behavior, wrong design decision, missed requirement — follow this loop exactly:

```
1. UNDERSTAND
   Restate the correction in your own words:
   "I understand: [restatement of what was wrong and what should change]"
   Do not defend the previous implementation. Do not explain why you did it.

2. FIX PLAN
   Produce a written fix plan:
   "Here is how I will fix this:
   - [change 1]: [what, which file/layer, why this fixes the issue]
   - [change 2]: ...
   - Tests affected: [list]
   - Backlog changes: [if any]"
   Ask: "Does this fix plan look right?"

3. WAIT FOR CONFIRMATION
   ↳ User says YES → go to step 4
   ↳ User says NO or gives more feedback → go back to step 1, refine understanding

4. IMPLEMENT
   Execute the fix plan with the same atomic commit discipline as the sprint:
   - fix(scope): [description of correction]

5. RETURN TO CHECKPOINT
   After implementation, return to Step 4a checkpoint format:
   "Fix applied. Here is the updated state: ..."
   Ask: "Is this now going the way you wanted?"
   ↳ User confirms → proceed to next sprint
   ↳ User gives another correction → restart Correction Protocol from step 1
```

**Rules:**
- Never implement a correction without first restating it and getting a plan confirmed
- Never batch multiple corrections silently — one correction loop at a time
- The fix plan must name specific files/layers; vague plans ("I'll update the UI") are not acceptable

#### 4c — Early Checkpoint Triggers

Pause mid-sprint and run the checkpoint immediately if:
- A feature turns out significantly more complex than the sprint plan assumed
- A technical decision would visibly affect UX (navigation pattern, data model shape, state management choice)
- Scope ambiguity: two reasonable interpretations exist and choosing wrong wastes the sprint
- User requests a scope or priority change mid-sprint — stop current work, commit whatever is clean, and run the checkpoint before proceeding
- Context window reaches 70%

---

## Final Ship (after user confirms "ship it")

**Skills:** `devfleet`, `superpowers:dispatching-parallel-agents`, `superpowers:requesting-code-review`, `gsd:ship`

Only run when the user explicitly decides the app is ready to ship — not automatically after any sprint.

1. Run full verification (same as Sprint Verification above)
2. Launch **4 parallel review agents** via `devfleet` or `superpowers:dispatching-parallel-agents`:

| Agent | Lens | Key checks |
|-------|------|-----------|
| **Architecture** | SOLID, layer boundaries | ISP/DIP violations, fat interfaces, presentation→data imports |
| **Security** | OWASP Mobile Top 10 | Insecure storage, secrets in source, missing obfuscation, PII in logs |
| **Flutter/Dart** | Quality & performance | Widget-returning methods (must be extracted `StatelessWidget`s), missing `const`, lazy builders (`ListView.builder` etc.), `RepaintBoundary` on expensive subtrees, `compute`/`Isolate.run` for heavy work, `Opacity` vs `FadeTransition`, image `cacheWidth`/`cacheHeight`, touch targets |
| **TDD Coverage** | Test completeness | Untested error paths, weak mocks, missing golden tests, coverage gaps |

3. Synthesize reports — fix all CRITICAL and HIGH findings
4. `gsd:ship` → PR

---

## Backlog Management

Maintain a `BACKLOG.md` in the project root from Sprint 1 onward:

```markdown
# App Backlog

## Sprint 1 (done)
- [x] Navigation shell
- [x] Placeholder screens

## Sprint 2 (current)
- [ ] Feature A
- [ ] Feature B

## Later
- Feature C
- Feature D
```

Update after every checkpoint based on user feedback.

---

## Additional Resources

- **`references/permissions-allow-list.md`** — Full allow list for `settings.local.json`
- **`references/fvm-flavors-setup.md`** — FVM install + 3-flavor scaffold commands
- **`references/clean-architecture-solid.md`** — Layer rules, ISP/DIP patterns, naming conventions
- **`references/tdd-patterns.md`** — Mock conventions, test file structure, commit patterns
- **`references/security-patterns.md`** — OWASP Mobile Top 10 checklist, Flutter security patterns
