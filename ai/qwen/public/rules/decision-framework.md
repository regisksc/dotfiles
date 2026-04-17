# Decision Framework: When / Where / How to Use AI

## 1) WHEN to Use AI

**Use AI for:**
- High repetition tasks
- Drafting and synthesis
- Data extraction and transformation
- Idea generation with rapid validation cycles

**Avoid AI when:**
- Legal or security risk is high without controls
- You need guaranteed deterministic output without checks

## 2) WHERE to Apply

| Domain | Applications |
|--------|--------------|
| **Career** | Code, documentation, test generation, review support |
| **Side income** | Lead processing, outreach prep, delivery generation |
| **Personal life** | Planning, reminders, budgeting, recurring admin |

## 3) HOW to Apply

Choose a mode:

| Mode | Description | When |
|------|-------------|------|
| **Manual support** | Human leads each step | High-risk, learning, critical tasks |
| **Assisted flow** | AI does subtasks with checks | Most development work |
| **Autonomous loop** | AI acts, human supervises at checkpoints | Well-defined, repetitive workflows |

## 4) Risk Triage

| Risk Level | Approach |
|------------|----------|
| **Low** | Fast iteration, minimal gates |
| **Medium** | Approval gate + logs |
| **High** | Explicit human approval + rollback plan |

## 5) Tool Suitability Matrix

| Tool | When to Use |
|------|-------------|
| **Prompt only** | Small tasks, low complexity |
| **Tool-calling** | External data/actions required |
| **RAG** | Domain context retrieval needed |
| **Multi-agent** | Large, decomposable tasks |
| **Workflow automation (n8n)** | Recurring operational flows |

## 6) Go/No-Go Checklist

Before starting:
- [ ] Objective is clear
- [ ] Inputs are validated
- [ ] Policy/legal constraints verified
- [ ] Observability and rollback exist
- [ ] Owner and escalation path defined

## Integration with Skills

- **Low risk + small task:** Direct execution
- **Medium risk + multi-step:** `/write-plan` first, then execute with checkpoints
- **High risk:** `/brainstorm` for approach, explicit user approval before each phase
- **Multi-agent:** `dispatching-parallel-agents` for independent subtasks
