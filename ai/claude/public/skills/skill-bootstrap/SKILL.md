---
name: skill-bootstrap
description: MANDATORY FIRST TURN CHECK - Must run before ANY task to check if other skills should be invoked
type: bootstrap
priority: 0
---

# SKILL INVOCATION CHECK - MANDATORY FIRST TURN

**This skill MUST be checked before responding to ANY user request.**

## Pre-Action Checklist

**BEFORE responding to ANY user request, you MUST:**

1. [ ] **SCAN** for skill keywords in the user's request
2. [ ] **CHECK** available skills for matches
3. [ ] **INVOKE** the matching skill BEFORE proceeding
4. [ ] **WAIT** for skill content to load
5. [ ] **FOLLOW** skill instructions exactly

## Skill Keyword Triggers

| If user mentions... | Invoke skill... |
|---------------------|-----------------|
| "bug", "broken", "error", "not working" | `systematic-debugging` |
| "performance", "slow", "lag", "cpu", "memory" | `systematic-debugging` |
| "research", "analyze", "investigate", "deep dive" | `deep-research` |
| "banner", "design", "creative", "social media" | `banner-design` |
| "commit", "git commit" | `commit-work` |
| "plan", "roadmap", "strategy" | `make-plan` |
| "test", "testing", "write tests" | `test-driven-development` |
| "spellcheck", "spelling", "typo" | `spellcheck` |
| "context", "large file", "many files" | `context-mode-usage` |
| "claude code" skill, compatibility | `claude-code-compat` |

## Invocation Pattern

When a keyword match is found:

1. **STOP** - Do not answer the request yet
2. **INVOKE** the matching skill with `/skillname` or `use_skill`
3. **WAIT** for skill content to load
4. **FOLLOW** the skill instructions exactly
5. **THEN** respond to the user

## No Match Found?

If no skill keywords match, proceed with normal task execution.

## Per-Turn Reminder

**This check applies to EVERY turn.** Skills may become relevant mid-conversation as the task evolves.

---

**FAILURE TO CHECK SKILLS BEFORE RESPONDING IS A SKILL VIOLATION.**
