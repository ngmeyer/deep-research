# Deep Research

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet?logo=anthropic)](https://claude.ai/code)
[![GitHub Stars](https://img.shields.io/github/stars/ngmeyer/deep-research?style=social)](https://github.com/ngmeyer/deep-research)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)]()

A Claude Code skill that researches any topic across multiple search providers simultaneously, extracts cross-referenced findings with confidence scores, builds an evidence matrix, surfaces contradictions, and produces cited research briefs.

Works with zero API keys. Improves with each provider you add.

## How It Works

```
Topic/Question
      |
  PLAN (interactive research plan — user approves subtopics)
      |
  DISCOVER (parallel: WebSearch + Tavily + Exa)
      |
  SYNTHESIZE (claims + cross-refs + evidence matrix + contradictions)
      |
  CRITIQUE (--deep only: adversarial review + gap-fill loop-back)
      |
  Research Brief + Evidence Matrix + Key Findings in chat
```

Three phases with an interactive planning step. Complexity lives in search quality and synthesis rigor, not pipeline overhead.

## Install

```bash
git clone https://github.com/ngmeyer/deep-research.git
cd auto-research

# Global install
mkdir -p ~/.claude/skills/deep-research
cp SKILL.md ~/.claude/skills/deep-research/SKILL.md

# Or per-project
mkdir -p .claude/skills/deep-research
cp SKILL.md .claude/skills/deep-research/SKILL.md
```

## Usage

```
/deep-research state of AI agents in 2026
/deep-research --quick what is DMAD in multi-agent debate?
/deep-research --deep Tavily vs Exa vs Perplexity for agent search
/deep-research --agent --save docs/research/competitors.md competitor landscape for X
```

## Modes

| Mode | Flag | Sources | Critique | Best For |
|------|------|---------|----------|----------|
| **Quick** | `--quick` | 3-5 | No | Fast answers |
| **Standard** | (default) | 8-15 | No | Most questions |
| **Deep** | `--deep` | 15-30 | Yes + loop-back | High-stakes research |
| **Agent** | `--agent` | Standard | No | Autonomous, saves file |

## Search Providers

| Provider | Best At | Requires |
|----------|---------|----------|
| **WebSearch** | General queries, broad coverage | Nothing (built-in) |
| **Tavily** | Structured retrieval, recent events | Tavily MCP connected |
| **Exa** | Semantic search, academic content | Exa MCP connected |

The skill detects available providers automatically. With zero API keys, it uses WebSearch only and flags the limitation. Each provider you add broadens coverage without changing the workflow.

## Output

```markdown
# Research Brief: [Topic]

*12 sources consulted across WebSearch, Tavily, Exa. Apr 13, 2026.*

## Key Findings

### F1: [Atomic claim as title]
[Synthesis with inline [S1], [S3] citations]
**Confidence:** High | **Triangulation:** 3 sources, 2 methods
**Cross-refs:** Extends F2. Contradicts F4 on [specific dimension].

### F2: [Atomic claim as title]
...

## Evidence Matrix

| Finding | S1 | S2 | S3 | S4 | S5 |
|---------|:--:|:--:|:--:|:--:|:--:|
| F1      | +  |    | +  |    | +  |
| F2      | +  | -  | +  | +  |    |

*Legend: + supports, - contradicts, blank = not addressed*

## Analysis
[Synthesis: what the findings mean together, referencing F1, F2, etc.]

## Contradictions & Tensions
[Both sides with source IDs and reasoning]

## Terminology Map
[Canonical terms with source-specific aliases]

## Knowledge Gaps
[Unanswered questions, missing perspectives, stale data]

## Sources
| ID | Title | Author | Date | Type | Cited by |
|----|-------|--------|------|------|----------|
| S1 | [title](url) | [author] | [date] | academic | F1, F2 |
```

## Why This Works

1. **Interactive research plan** -- You approve the subtopics before searching starts. Add, remove, or refine angles. Inspired by Google Deep Research.
2. **Multi-perspective search** -- Generates 2-4 query angles per topic (technical, market, practitioner, contrarian). Catches what single-angle search misses. Inspired by Stanford's STORM framework.
3. **Cross-referenced findings** -- Every finding gets an ID (F1, F2). Cross-refs show which findings extend, contradict, or qualify each other. Navigate the brief like a knowledge graph.
4. **Evidence matrix** -- One table shows which sources support or contradict each finding. See convergence and divergence at a glance.
5. **Confidence scoring with triangulation** -- Per-claim HIGH / MEDIUM / LOW / CONFLICTING with explicit triangulation type (data, methodological, perspective).
6. **Contradiction surfacing** -- When sources disagree, both sides are presented with source IDs and reasoning. Conflicts are features, not bugs.
7. **Terminology map** -- When sources use different names for the same concept, a canonical term is established with aliases. No confusion from jargon.
8. **Knowledge gaps** -- Explicit section listing what the research couldn't answer. Missing perspectives, stale data, unanswered questions.
9. **Graceful degradation** -- Zero-config WebSearch fallback. No "install these 5 tools first" barrier.
10. **Critique loop-back** (deep mode) -- Adversarial self-review identifies gaps, runs targeted follow-up searches, re-scores claims.

## What It Won't Do

- Generate 30-page reports nobody reads
- Hide contradictions between sources
- Tag everything as "high confidence"
- Require API keys to function
- Search infinitely without producing output

## Credits

- Skill by: **Neal Meyer**
- Multi-perspective search: **Stanford STORM** ([NAACL 2024](https://github.com/stanford-oval/storm))
- Critique loop-back: **199-biotechnologies** ([claude-deep-research-skill](https://github.com/199-biotechnologies/claude-deep-research-skill))
- Confidence scoring: **CRAAP Framework**

## License

MIT
