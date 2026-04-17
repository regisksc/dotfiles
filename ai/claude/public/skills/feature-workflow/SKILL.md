---
name: feature-workflow
description: Standardized workflow for building new features, from planning to implementation and memory persistence.
---

# Feature Workflow

Trigger: user says "feature workflow" or `/feature-workflow`

Follow these steps sequentially to implement a new feature:

1. **Context Loading**: Run `mempalace wake-up` to load recent session context.
2. **System Visualization**: Use `graphify` to visualize the codebase areas that will be affected.
3. **Planning & Brainstorming**: Use the superpowers brainstorming skill to plan the feature.
4. **Implementation**: Implement the feature using the TDD (Test-Driven Development) skill.
5. **Knowledge Persistence**: After merging/completion, run `mempalace mine` and `graphify` to update the knowledge graph.
