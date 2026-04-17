# Global Configuration — Skills + Context-Mode

## Priority Rules (GLOBAL)

1. **SKILLS FIRST** — If a specialized skill exists for the task, USE IT. Skills encode expert knowledge that generic assistance cannot replicate.
2. **context-mode for data** — Use context-mode MCP tools for research, file analysis, web fetching, and data processing.

## Skill Usage Rule

**ALWAYS check for and use a skill when:**
- The task matches a skill's specialty (writing, security, testing, deployment, etc.)
- A skill would produce higher-quality output than generic assistance
- The user explicitly requests skill usage

### Common Skill Triggers

| Task | Skill |
|------|-------|
| Humanize text, remove AI patterns | `humanizer` |
| Security review | `security-review` |
| Testing (any language) | `tdd-workflow`, `python-testing`, etc. |
| Flutter development | `flutter-*` skills |
| Code quality/linting | `plankton-code-quality` |
| UI/UX design | `ui-ux-pro-max` |
| Research/exploration | `smart-explore` |
| Writing content | `article-writing`, `content-engine` |
| API design | `api-design` |
| Database work | `postgres-patterns`, `database-migrations` |

## Tool Selection Hierarchy (when no skill applies)

1. **GATHER:** `ctx_batch_execute(commands, queries)` — research, exploration
2. **FOLLOW-UP:** `ctx_search(queries: [...])` — query indexed content
3. **PROCESSING:** `ctx_execute(language, code)` — sandbox execution
4. **WEB:** `ctx_fetch_and_index(url, source)` — fetch documentation
5. **INDEX:** `ctx_index(content, source)` — store for later

## Blocked Commands

| Instead of | Use |
|------------|-----|
| `curl`, `wget` | `ctx_fetch_and_index(url, source)` |
| `cat`, `head`, `tail` (analysis) | `ctx_execute_file(path, language, code)` |
| `grep`, `rg` (large output) | `ctx_execute()` or `ctx_search()` |

## Rules

1. **SKILLS FIRST** — Check skills BEFORE context-mode
2. **context-mode for data** — Not for creative/specialized tasks
3. **NEVER** use curl/wget in bash — route to sandbox
4. **NEVER** read files for analysis — use `ctx_execute_file`
5. Keep responses concise (<500 words unless user asks for detail)
6. Write artifacts to FILES — return path + 1-line description



## Enforcement Mechanisms

| Mechanism | Location | Effect |
|-----------|----------|--------|
| Skill selection | `CLAUDE.md:9-30` | Advisory (agent reads before acting) |
| Tool hierarchy | `CLAUDE.md:31-38` | Advisory |
| RTK auto-rewrite | `plugins/rtk-rewrite.ts` | **Enforced** (mutates commands) |
| Tool selection block | `plugins/tool-selection.ts` | **Enforced** (throws on blocked commands) |
| Bash permissions | `opencode.json` | **Enforced** (requires approval for blocked commands) |
| context-mode MCP | `mcp.json` | Available as tool option |

## Blocked Commands (Hard Block)

These will throw an error if attempted via bash:
- `curl`, `wget` → use `webfetch` or `ctx_fetch_and_index`
- `cat` → use `read` or `ctx_execute_file`
- `grep`, `rg` → use `grep` tool or `ctx_search`
- `find` → use `glob` tool
- `head`, `tail` → use `read` with offset/limit


# AI OPERATIONAL DEFAULTS & WORKFLOWS

## Token Efficiency Stack (always active)
Layer 1: Caveman lite (default) — 30% token savings, professional tone
Layer 2: Context-mode sandbox — route ALL large outputs (>20 lines) through ctx_execute
Layer 3: MemPalace — check for relevant past work before starting any task
Layer 4: Skill routing — check if a specialized skill exists before doing anything generically

## Tool Selection Logic
IF task matches a skill → use that skill
IF need library/framework docs → context7 MCP
IF need past session context → mem-search / mempalace search  
IF need to analyze large output → context-mode sandbox
IF need to understand codebase structure → graphify query
IF task is complex + decomposable → openspace execute_task to delegate
IF need external research → deep-research skill (quick mode)
ELSE → handle directly with caveman lite active

## Automatic Behaviors (no user prompt needed)
1. **Session start:** Silently check `mempalace search "handoff" --recent 1h`. If results, load context.
2. **Before any task:** Check if a skill matches. 170+ skills available — use `search_skills` via OpenSpace MCP or scan `~/.claude/skills/` directory names.
3. **Large data:** Never dump raw logs/output into context. Use `ctx_batch_execute` or `ctx_execute_file`.
4. **Cross-session memory:** Use `mem-search` / `smart_search` to find if this problem was solved before.
5. **After significant work:** Run `graphify .` to update knowledge graph. Run `mempalace mine` to persist insights.
6. **When user says "caveman [level]":** Switch immediately, maintain for session. Levels: lite/full/ultra/wenyan-lite/wenyan-full/wenyan-ultra.
7. **When user says "handoff":** Summarize current work state, store via mempalace for the next tool to pick up.
8. **When context monitor warns (35%):** Proactively suggest /compact, mine mempalace first to preserve context.
9. **Task delegation:** For complex multi-step tasks, use OpenSpace `execute_task` to delegate sub-tasks to specialized agents.
10. **Documentation lookup:** Use context7 MCP for library docs before guessing APIs.

# Component Systems


## Proactive Tool Utilization
You are equipped with advanced CLI and MCP tools (like MemPalace, OpenSpace, Graphify, and context-mode). DO NOT just read these instructions and assume you know the state of the system — verify it.
- **When asked about the status of the system, an integration, or your operational mode:** Use your terminal tools, file viewing tools, or MCP tools to actively inspect the configuration before answering. 
- Example: If asked if "Caveman" is on or if "MemPalace is integrated", read your loaded instructions, check the relevant JSON configs (`~/.claude/settings.json`, `~/.openclaw/openclaw.json`, `~/.config/opencode/opencode.json`), or invoke the tool directly to see if it responds. Act like a diagnostic assistant.

## Caveman Mode (AI Communication Style — NOT a game feature)
**IMPORTANT:** "Caveman" refers to YOUR communication style, NOT to any game content. It is NEVER about game characters, enemies, or features.
Default caveman level: **lite** (new sessions start here — caveman is ALWAYS ON by default).
When user says "caveman [level]" (lite/full/ultra/wenyan-lite/wenyan-full/wenyan-ultra), switch immediately and maintain for rest of session.
When user says "stop caveman" or "normal mode", revert to standard communication.
Current session level is determined by the last user instruction — do NOT persist across sessions.



## Auto-Mining
Before ending a significant work session (user says goodbye, /compact, or context is critically low), proactively run: `mempalace mine ./ --wing git --mode convos`

## Context Handoff
On session start, silently check: `mempalace search "handoff" --recent 1h`
If results found, load that context before proceeding.
When user says "handoff" or "switching tools", summarize current work state and store via mempalace.

## Graphify
After completing significant code changes (new files, architecture changes), run `graphify .` to update the knowledge graph. Use `/graphify` skill for in-conversation graph queries.


### Project Auto-Memory Vault (Obsidian & MemPalace Stack)
- **Always Verify The Local Vault:** Every project now has a local `.ai-vault` folder containing Obsidian notes. It serves as your primary context hub.
- **Write Memory Drops On Action:** ANY time you execute ANY codebase analysis skill (like `systematic-debugging`, `codebase-analysis`, `gsd`, etc.), perform context-handoffs, or produce meaningful code structure changes, YOU MUST log a memory note.
- **Note Formatting:** 
   - Write the exact same file to BOTH locations simultaneously:
     1. Local: `.ai-vault/YYYY-MM-DD_HH-mm_Brief_Description.md`
     2. Global Root Vault Aggregator: `~/macbookm2pro-root/AI-Memories/<Project_Name>/YYYY-MM-DD_HH-mm_Brief_Description.md`
   - Structure mandatory: Obsidian YAML frontmatter containing `title`, `date`, `description`, `tags`.
   - Content: Briefly but comprehensively log the architectural decisions made, files changed, and the precise reasoning.
- **Auto-Sync Trigger:** After writing the memory files, you must silently execute `mempalace mine .ai-vault` in Bash to guarantee the wider system absorbs the new context.
