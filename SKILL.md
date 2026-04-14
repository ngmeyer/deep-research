---
name: deep-research
description: >
  Multi-source deep research that produces cited, confidence-scored briefs.
  Searches across Exa, Tavily, and web in parallel. Extracts claims, scores
  confidence, surfaces contradictions. Works with zero API keys (WebSearch
  fallback), improves with each provider added.
  Use when: 'research this', 'deep research', 'deep research', 'investigate',
  'what do we know about', 'find out about', or any open-ended research question.
user-invocable: true
allowed-tools: ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Agent", "WebFetch", "WebSearch", "mcp__claude_ai_Tavily__tavily_search", "mcp__claude_ai_Tavily__tavily_extract", "mcp__claude_ai_Tavily__tavily_research", "mcp__claude_ai_Exa__web_search_exa", "mcp__claude_ai_Exa__web_fetch_exa"]
argument-hint: "<topic or question> [--quick] [--deep] [--agent] [--save path/to/output.md]"
---

# Deep Research — Multi-Source Research with Cross-Referencing

Research any topic across multiple search providers simultaneously. Produces a confidence-scored research brief with cross-referenced findings, evidence matrix, contradiction surfacing, and structured source tracking.

## Core Design

**Three phases with an interactive planning step.** Complexity lives in search quality and synthesis rigor, not pipeline overhead.

```
PLAN (interactive) → DISCOVER (parallel) → SYNTHESIZE (cross-reference) → CRITIQUE (--deep only)
```

**Graceful degradation.** Works with zero API keys using Claude's built-in WebSearch. Each additional provider (Tavily, Exa) adds coverage without changing the workflow.

| Provider | Best At | Requires |
|----------|---------|----------|
| WebSearch | General queries, broad coverage | Nothing (built-in) |
| Tavily | Structured retrieval, recent events, RAG-native output | Tavily MCP connected |
| Exa | Semantic/conceptual search, academic content, "find similar" | Exa MCP connected |

## Modes

| Mode | Flag | Sources | Critique | Best For |
|------|------|---------|----------|----------|
| **Quick** | `--quick` | 3-5 | No | Fast answers, gut-checks |
| **Standard** (default) | none | 8-15 | No | Most research questions |
| **Deep** | `--deep` | 15-30 | Yes (loop-back) | High-stakes, publishable research |
| **Agent** | `--agent` | Standard | No | Autonomous, non-interactive |

Combine flags: `--deep --save docs/research/topic.md`

## Arguments

- **Argument 1 (required):** Research topic or question
- **`--quick`:** Fast mode, fewer sources, no critique
- **`--deep`:** Thorough mode, more sources, adversarial critique with loop-back
- **`--agent`:** Non-interactive, saves report without asking, exits cleanly
- **`--save <path>`:** Write the research brief to this file path

---

## Procedure

### Phase 0: Frame the Research

Parse flags from `$ARGUMENTS`. Remove flags, remainder is the research topic.

**Classify the query type:**

| Type | Signal | Affects Search Strategy |
|------|--------|------------------------|
| **Factual** | "What is...", "When did...", "How does..." | Prioritize authoritative sources, verify facts |
| **Comparative** | "X vs Y", "compare", "difference between" | Run parallel searches for each entity |
| **Exploratory** | "What's happening with...", "state of..." | Cast wide net, prioritize recency |
| **Forecasting** | "Will...", "future of...", "predictions" | Include prediction markets, expert opinions |

**Generate 2-4 search perspectives** (inspired by STORM):
- Don't search from one angle. For "state of AI agents in 2026", generate:
  - Technical: "AI agent frameworks architectures 2026"
  - Market: "AI agent companies funding revenue 2026"
  - Practitioner: "AI agent developer experience pain points 2026"
  - Contrarian: "AI agent limitations failures overhyped 2026"

Each perspective becomes a parallel search query.

### Phase 0b: Research Plan (interactive, skip in --quick and --agent)

Before searching, generate a structured research plan and present it to the user for approval. This is the most impactful quality lever — it ensures the research covers the right angles.

```
## Research Plan: [Topic]

I'll investigate these angles:
1. [Subtopic A] — [what we're looking for, which perspective]
2. [Subtopic B] — [what we're looking for]
3. [Subtopic C] — [contrasting viewpoint or edge case]
4. [Subtopic D] — [practical/applied angle]

Estimated: [N] sources across [available providers].

Adjust this plan or say "go" to start.
```

The user can add/remove subtopics, refine scope, or approve as-is. Each approved subtopic becomes a search perspective in Phase 1.

In `--quick` mode: skip the plan, use the auto-generated perspectives from Phase 0.
In `--agent` mode: skip the plan, proceed autonomously.

### Phase 1: DISCOVER — Parallel Multi-Source Search

**Detect available providers** by attempting to use each tool. If a tool call fails with "not available" or similar, fall back gracefully.

**Search strategy by provider:**

```
For each search perspective (2-4 queries):

  WebSearch (always available):
    - Search the query
    - Read top 2-3 results via WebFetch for full content

  Tavily (if available):
    - tavily_search with search_depth="advanced" for structured results
    - tavily_extract on the most promising URLs for full content

  Exa (if available):
    - web_search_exa for semantic matches (catches what keyword search misses)
    - web_fetch_exa on top results for content

  Deduplicate by URL across providers.
```

**Source targets by mode:**

| Mode | WebSearch | Tavily | Exa | Total Target |
|------|-----------|--------|-----|-------------|
| Quick | 3-5 results | 2-3 | 2-3 | 3-5 unique |
| Standard | 5-8 results | 3-5 | 3-5 | 8-15 unique |
| Deep | 8-12 results | 5-8 | 5-8 | 15-30 unique |

**For each source, capture:**
- URL
- Title
- Author (if available)
- Date (if available)
- Source type: `academic` | `news` | `blog` | `official` | `social` | `forum`
- Full content or relevant excerpt

**Write-after-every-search rule:** After each batch of searches completes, write a brief progress note. This prevents agent loops and ensures partial results survive context compaction.

### Phase 2: SYNTHESIZE — Claims, Confidence, Contradictions

Process all discovered sources in a single synthesis pass. This is where the research brief takes shape.

**Step 2a: Assign IDs and extract atomic claims**

Assign each source an ID (`S1`, `S2`, ...) as it's processed. For each source, extract discrete factual claims. A claim is a single assertion with a subject, verb, and specific value:
- YES: "Tavily was acquired by Nebius in February 2026" `[S3]`
- NO: "Tavily is a popular search tool" (vague, not falsifiable)

Each finding gets an ID (`F1`, `F2`, ...) for cross-referencing.

**Step 2b: Coreference pass — group related claims**

Before scoring, identify claims that refer to the same phenomenon using different terminology. Group them under a canonical term:
- If Source A calls it "context window stuffing" and Source B calls it "retrieval augmentation" but they describe the same mechanism, merge into one finding with a note listing alternate terms.
- If two claims seem similar but differ meaningfully (scope, mechanism, conditions), keep them separate and note the distinction.

**Step 2c: Score confidence with triangulation**

| Confidence | Criteria | Triangulation | Marker |
|------------|----------|---------------|--------|
| **High** | 3+ independent sources agree | Data or methodological triangulation | No marker needed |
| **Medium** | 1-2 credible sources | Single-method confirmation | *(medium confidence)* |
| **Low** | Single source, or blog/social only | No triangulation | *(unverified)* |
| **Conflicting** | Sources directly contradict | — | *(sources conflict — see Evidence Matrix)* |

**Step 2d: Build cross-references**

For each finding, note:
- Which sources support it (by ID)
- Which findings it relates to (extends, contradicts, or qualifies)
- Which search perspectives surfaced it

**Step 2e: Write the research brief**

Structure the output using the cross-referenced template:

```markdown
# Research Brief: [Topic]

*[N] sources consulted across [providers used]. [Date]. Mode: [quick/standard/deep].*

## Key Findings

### F1: [Atomic claim as title]
[1-3 sentence synthesis with inline [S1], [S3] citations]
**Confidence:** High | **Triangulation:** 3 sources, 2 methods
**Cross-refs:** Extends F2. Contradicts F4 on [specific dimension].

### F2: [Atomic claim as title]
[synthesis with [S2], [S4] citations]
**Confidence:** Medium | **Triangulation:** 2 sources, same method
**Cross-refs:** Builds on F1.

[5-10 findings for standard, 3-5 for quick, 10-15 for deep]

## Evidence Matrix

| Finding | S1 | S2 | S3 | S4 | S5 |
|---------|:--:|:--:|:--:|:--:|:--:|
| F1 | + | | + | | + |
| F2 | + | - | + | + | |
| F3 | | + | | | - |

*Legend: + supports, - contradicts, blank = not addressed*

## Analysis

[2-4 paragraphs synthesizing the findings into a coherent narrative.
Don't just list facts — explain what they mean together.
Flag where the evidence is strong vs. where it's thin.
Reference findings by ID (F1, F2) so the reader can trace back.]

## Contradictions & Tensions

[For each contradiction, present both sides with source IDs:]
> **F2 vs F3:** [S2] claims X, but [S5] found the opposite when [condition].
> Resolution likely depends on [factor].

## Terminology Map

| Canonical Term | Also Called (by source) |
|---------------|----------------------|
| [term] | "[alt1]" [S1], "[alt2]" [S3] |

[Include only when sources use different names for the same concept.
Omit this section if no terminology conflicts were found.]

## Knowledge Gaps

> **[Gap]** No source addressed [specific unanswered question].
> **[Gap]** All sources predate [date] — no data on [recent development].
> **[Gap]** Only [perspective] was represented — [missing perspective] not found.

## Sources

| ID | Title | Author | Date | Type | Cited by |
|----|-------|--------|------|------|----------|
| S1 | [title](url) | [author] | [date] | academic | F1, F2, F4 |
| S2 | [title](url) | [author] | [date] | official | F2, F3 |
```

### Phase 3: CRITIQUE — Adversarial Review (--deep only)

Only runs in `--deep` mode. Skip for standard and quick.

**Step 3a: Adversarial self-review**

Review the draft brief and ask:
- Which key findings rely on a single source? Flag as fragile.
- Which claims could be outdated? Check dates.
- What perspectives are missing? What would a skeptic ask?
- Are there obvious search queries we didn't try?

**Step 3b: Gap-filling (loop-back)**

If the critique identifies 1-3 specific gaps:
- Generate targeted delta-queries for each gap
- Run additional searches (Phase 1, scoped to gaps only)
- Integrate new findings into the brief
- Maximum 1 loop-back to prevent infinite recursion

**Step 3c: Confidence recalibration**

After gap-filling, re-score any claims that gained or lost supporting sources.

### Phase 4: DELIVER

**Show key findings inline in chat** — the user shouldn't need to open a file to see results.

Present the top 5-7 findings with confidence markers directly in the conversation.

**Save the full brief** if `--save` flag is present or `--agent` mode:
- Default path: `docs/research/YYYY-MM-DD-[topic-slug].md`
- Custom path via `--save path/to/file.md`
- Create directories as needed

**In `--agent` mode:** Save the brief, print the file path, exit. No questions asked.

**In interactive mode:** Show findings in chat, then ask:
- "Save this brief?" (with suggested path)
- "Research deeper on any finding?"
- "Done"

---

## Fallback Behavior

| Scenario | Behavior |
|----------|----------|
| No Tavily, no Exa | WebSearch + WebFetch only. Flag: "Limited to web search — install Tavily or Exa MCP for broader coverage" |
| No WebSearch available | Use only Tavily/Exa. If neither available, use training knowledge only and flag EVERY claim as *(unverified — no search tools available)* |
| Search returns <3 results | Flag: "Limited results found. Consider broadening the query or checking search connectivity." |
| Source content too long | Summarize key sections, cite page/section, link to full source |

## What NOT to Do

- **No 30-page reports.** Keep briefs to 1-3 pages. Depth comes from claim quality, not word count.
- **No hidden contradictions.** If sources disagree, surface it. Don't silently pick a winner.
- **No confidence theater.** Don't tag everything as [HIGH] — if you only found one source, say so.
- **No unsourced claims.** Every factual assertion needs a citation. Synthesis and analysis can be uncited (they're your reasoning), but facts need sources.
- **No search loops.** Write-after-every-search prevents infinite searching. Maximum 1 critique loop-back in deep mode.
- **No provider shaming.** Don't tell users they need API keys. Work with what's available and note when broader coverage would help.

## Credits

Skill by: Neal Meyer
Multi-perspective search: Inspired by Stanford STORM framework
Critique loop-back pattern: Informed by 199-biotechnologies/claude-deep-research-skill
Confidence scoring: Adapted from CRAAP framework
