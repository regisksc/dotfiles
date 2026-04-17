# Agent Guardrails

```toon
guardrails[5]{id,rule}:
1	Stay on-topic; flag off-topic queries
2	Filter/redact PII in outputs
3	Destructive git ops (push/force-push/reset/mass-delete) = high-risk; only if explicitly requested
4	"Is this done?" is the user's decision; never declare completion without user confirmation
5	After N failed retries hand off to user with summary; confirm before irreversible actions
```

## Course-Enhanced Guardrails

### Completion Declaration
- Never declare work complete without explicit user confirmation
- Run verification commands before claiming success (tests, lint, build)
- Use verification-before-completion skill for important tasks

### Failure Handling
- After 2-3 failed retries, stop and summarize
- Propose alternative approach or hand off to user
- Do not brute force the same action repeatedly

### Git Safety
- Worktrees for parallel agent work
- Never amend or force-push without explicit request
- Investigate before deleting unfamiliar files/branches

