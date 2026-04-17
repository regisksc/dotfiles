---
name: deep-research-wrapper
description: Wrapper for deep-research skill that enforces parallel execution and methodology compliance. Use when deep-research skill is invoked to ensure proper 8-phase pipeline execution.
---

# Deep Research Wrapper

## Purpose

This wrapper skill ensures the deep-research skill executes its full 8-phase methodology with parallel search strategy, sub-agent spawning, and quality gates.

## When to Use

Invoke this skill BEFORE or INSTEAD of calling deep-research directly when:
- User requests "deep-research" in ultra-deep mode
- Research requires 30+ sources with triangulation
- Full 20-45 minute pipeline execution is expected

## Execution Protocol

### Step 1: Enforce Parallel Search (Phase 3)

When the deep-research skill is invoked, you MUST:

1. **Spawn 5-10 parallel WebSearch calls in a SINGLE message:**
   - Core topic (semantic search)
   - Technical details (keyword search)
   - Recent developments (date-filtered, use current year)
   - Academic sources (arxiv.org, scholar.google.com)
   - Alternative perspectives (comparison/criticism)
   - Statistical/data sources
   - Industry analysis
   - Critical analysis/limitations

2. **Spawn 3-5 sub-agents in the SAME message:**
   ```
   Agent({
     description: "Academic paper analysis",
     subagent_type: "general-purpose",
     prompt: "Deep dive into academic papers from [CURRENT_YEAR]..."
   })
   Agent({
     description: "Industry analysis",
     subagent_type: "general-purpose", 
     prompt: "Analyze industry reports and market data..."
   })
   Agent({
     description: "Technical deep dive",
     subagent_type: "general-purpose",
     prompt: "Extract technical specifications and implementations..."
   })
   ```

### Step 2: Enforce Quality Gates

**Do NOT proceed to synthesis until:**
- 30+ sources collected (ultra-deep mode)
- Average credibility score >75/100
- Source diversity: 3+ types (academic, industry, news, technical)
- Temporal diversity: mix of recent 12-18 months + foundational

### Step 3: Enforce Triangulation (Phase 4)

For EVERY major claim:
- Verify across 3+ independent sources
- Flag single-source information
- Note consensus vs. debate areas

### Step 4: Enforce Critique (Phase 6)

Before finalizing report:
- Run red-team questions
- Simulate 2-3 critic personas
- Check for logical consistency
- Verify citation completeness

### Step 5: Enforce Output Contract

Final report MUST have:
- Executive Summary (200-400 words)
- Introduction with methodology
- 4-8 findings (600-2,000 words each, cited)
- Synthesis & Insights
- Limitations & Caveats
- Recommendations
- Complete bibliography (no placeholders)
- Methodology appendix

## Anti-Patterns to Reject

If the deep-research skill attempts to:
- Complete in under 10 minutes (ultra-deep)
- Use fewer than 30 sources
- Skip triangulation phase
- Generate report without critique
- Use sequential instead of parallel execution

**STOP and enforce proper methodology.**

## Trigger

This wrapper activates automatically when:
- User invokes `/deep-research` with "ultra deep" mode
- Research query requires comprehensive analysis
- User explicitly mentions time expectation (20-45 min)
