---
name: research-workflow
description: Standardized workflow for exploring new topics, from fetching docs to synthesis and knowledge storage.
---

# Research Workflow

Trigger: user says "research workflow" or `/research-workflow`

Follow these steps sequentially to safely perform research:

1. **Information Gathering**: Use `ctx_fetch_and_index` for relevant documents and URLs.
2. **Context Querying**: Use `ctx_search` to query the indexed knowledge from step 1.
3. **Memory Lookup**: Run `mem-search` to uncover past research on the same or related topics.
4. **Synthesis**: Synthesize findings and present a concise summary.
5. **Knowledge Visualization**: Use `graphify` to turn the findings into part of the knowledge graph.
6. **Knowledge Persistence**: Use `mempalace` to store key insights and takeaways permanently.
