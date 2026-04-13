# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

Auto-Research is a Claude Code skill for multi-source deep research with confidence-scored claims, contradiction detection, and optional critique loop-back. Three-phase architecture: DISCOVER, SYNTHESIZE, CRITIQUE.

**Repo:** github.com/ngmeyer/auto-research
**Author:** Neal Meyer

## File Structure

```
auto-research/
├── SKILL.md      # The executable skill
├── README.md     # Install, usage, output examples
├── LICENSE        # MIT
└── CLAUDE.md      # This file
```

## Architecture

Prompt-only skill. No runtime code, no dependencies.

### Three Phases (Council-Reviewed)

The original design proposed 7 phases. Council review (5 advisors: Contrarian, First Principles, Expansionist, Outsider, Executor) reached consensus that complexity should live in search quality, not pipeline overhead. Reduced to 3 core phases:

```
Phase 1: DISCOVER  — parallel multi-provider search with perspective diversity
Phase 2: SYNTHESIZE — claim extraction, confidence scoring, contradiction surfacing
Phase 3: CRITIQUE   — adversarial review with gap-fill loop-back (--deep only)
```

### Key Design Decisions

- **3 phases, not 7.** Council's Contrarian proved that latency kills adoption — users abandon after 90 seconds. Standard mode must complete in under 60 seconds.
- **Graceful degradation.** Works with zero API keys (WebSearch only). Each additional provider (Tavily, Exa) adds coverage. Never block on missing tools.
- **Multi-perspective search (STORM pattern).** Generate 2-4 query angles per topic. This is the highest-impact quality lever — more important than adding search providers.
- **Confidence scoring is per-claim, not per-report.** HIGH/MEDIUM/LOW/CONFLICTING based on independent source count.
- **Contradictions are features.** Surface them explicitly instead of silently picking a winner.
- **Critique loop-back (deep only).** Maximum 1 loop to prevent infinite recursion. Most research doesn't need this.
- **Write-after-every-search.** Prevents agent loops and ensures partial results survive context compaction.
- **1-3 page briefs.** Peter Yang's insight: "I prefer Claude because it creates concise five-page reports I want to read instead of 30+ pages."

### Research Provenance

- Stanford STORM framework: multi-perspective questioning
- 199-biotechnologies: critique loop-back pattern
- CRAAP framework: source credibility scoring
- DMAD (ICLR 2025): method diversity for same-model agents
- altmbr/claude-research-skill: write-after-every-search anti-loop protocol
- Defiect/deep-research-plugin: structured claim/evidence artifacts

## Editing Guidelines

- **SKILL.md is the product.** Prompt changes are code changes.
- **Don't add phases.** The 3-phase design was council-reviewed. If you need more sophistication, add it within existing phases.
- **Don't require API keys.** Every feature must work with WebSearch fallback, even if degraded.
- **Test all modes.** Quick, Standard, Deep, and Agent modes all need verification after changes.

## Testing

1. `cp SKILL.md ~/.claude/skills/auto-research/SKILL.md`
2. `/auto-research --quick what is STORM framework` — should complete in <30s, 3-5 sources
3. `/auto-research state of AI coding assistants 2026` — should produce 8-15 sources, confidence-scored findings
4. `/auto-research --deep Tavily vs Exa for agent search` — should run critique loop, 15+ sources
5. Verify: contradictions surfaced (not hidden), confidence scores present, sources table complete

## Commit Style

Conventional Commits: `feat:`, `fix:`, `docs:`, `refactor:`
