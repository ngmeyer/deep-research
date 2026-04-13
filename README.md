# Auto-Research

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet?logo=anthropic)](https://claude.ai/code)
[![GitHub Stars](https://img.shields.io/github/stars/ngmeyer/auto-research?style=social)](https://github.com/ngmeyer/auto-research)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey)]()

A Claude Code skill that researches any topic across multiple search providers simultaneously, extracts confidence-scored claims, surfaces contradictions, and produces cited research briefs.

Works with zero API keys. Improves with each provider you add.

## How It Works

```
Topic/Question
      |
  DISCOVER (parallel: WebSearch + Tavily + Exa)
      |
  SYNTHESIZE (claims + confidence + contradictions)
      |
  CRITIQUE (--deep only: adversarial review + gap-fill loop-back)
      |
  Research Brief + Key Findings in chat
```

Three phases, not seven. Complexity lives in search quality and synthesis rigor, not pipeline overhead.

## Install

```bash
git clone https://github.com/ngmeyer/auto-research.git
cd auto-research

# Global install
mkdir -p ~/.claude/skills/auto-research
cp SKILL.md ~/.claude/skills/auto-research/SKILL.md

# Or per-project
mkdir -p .claude/skills/auto-research
cp SKILL.md .claude/skills/auto-research/SKILL.md
```

## Usage

```
/auto-research state of AI agents in 2026
/auto-research --quick what is DMAD in multi-agent debate?
/auto-research --deep Tavily vs Exa vs Perplexity for agent search
/auto-research --agent --save docs/research/competitors.md competitor landscape for X
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
1. **Finding** -- summary with inline citation *(high confidence)*
2. **Finding** -- summary *(medium confidence)*
3. **Finding** -- summary *(sources conflict -- see below)*

## Analysis
[Synthesis: what the findings mean together]

## Contradictions & Open Questions
[Conflicting claims with sources on each side]

## Sources
[Numbered table with title, publication, date, type]
```

## Why This Works

1. **Multi-perspective search** -- Generates 2-4 query angles per topic (technical, market, practitioner, contrarian). Catches what single-angle search misses. Inspired by Stanford's STORM framework.
2. **Confidence scoring** -- Every claim gets HIGH / MEDIUM / LOW / CONFLICTING based on source count and quality. No confidence theater.
3. **Contradiction surfacing** -- When sources disagree, both sides are presented with reasoning about which is more authoritative. Conflicts are features, not bugs.
4. **Graceful degradation** -- Zero-config WebSearch fallback. No "install these 5 tools first" barrier.
5. **Critique loop-back** (deep mode) -- Adversarial self-review identifies gaps, runs targeted follow-up searches, re-scores claims.
6. **Concise output** -- 1-3 page briefs. Depth from claim quality, not word count.

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
