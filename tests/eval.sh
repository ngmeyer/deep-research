#!/usr/bin/env bash
# Structural eval for deep-research.
#
# deep-research is a compound, prompt-only skill. Runtime output is
# non-deterministic (web search + synthesis). This eval asserts the
# design contract from CLAUDE.md: three phases, four modes, graceful
# degradation, and confidence-scoring taxonomy all still named in SKILL.md.
#
# Full behavioral eval (does a --deep run on a known topic produce the
# expected confidence distribution?) requires golden-run fixtures with
# recorded search results — deferred.
#
# Usage: bash tests/eval.sh
# Exit 0 on pass, 1 on any assertion failure.

set -u
cd "$(dirname "$0")/.."

PASS=0
FAIL=0
pass() { echo "PASS  $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL  $1"; FAIL=$((FAIL+1)); }
have() { grep -qF "$1" "$2"; }

echo "== Three-phase architecture =="
for phase in "DISCOVER" "SYNTHESIZE" "CRITIQUE"; do
  if have "$phase" SKILL.md; then pass "Phase named: $phase"; else fail "Phase missing: $phase"; fi
done

echo ""
echo "== Four modes =="
for flag in "\`--quick\`" "\`--deep\`" "\`--agent\`" "\`--save"; do
  if have "$flag" SKILL.md; then pass "Flag documented: $flag"; else fail "Flag missing: $flag"; fi
done

echo ""
echo "== Graceful degradation guarantee =="
if have "Graceful degradation" SKILL.md || have "graceful degradation" SKILL.md; then pass "Graceful degradation named"; else fail "Graceful degradation not claimed in SKILL.md"; fi
if have "WebSearch" SKILL.md; then pass "WebSearch fallback documented"; else fail "WebSearch fallback missing"; fi
if have "Tavily" SKILL.md && have "Exa" SKILL.md; then pass "Both optional providers (Tavily, Exa) named"; else fail "Optional providers not fully named"; fi

echo ""
echo "== Confidence scoring taxonomy =="
# Accept case-insensitive — SKILL.md uses Title Case in the rubric table
have_ci() { grep -qFi "$1" "$2"; }
for level in "High" "Medium" "Low"; do
  if have_ci "$level" SKILL.md; then pass "Confidence level present: $level"; else fail "Confidence level missing: $level"; fi
done
if have_ci "conflicting" SKILL.md || have_ci "contradict" SKILL.md; then
  pass "Contradiction handling acknowledged"
else
  fail "Contradictions/CONFLICTING class not named"
fi

echo ""
echo "== Anti-loop invariants (from CLAUDE.md) =="
if grep -qFi "write-after-every-search" SKILL.md || grep -qFi "write after every search" SKILL.md; then
  pass "Write-after-every-search anti-loop pattern named"
else
  fail "Write-after-every-search anti-loop missing"
fi
if have "STORM" SKILL.md || have "perspective" SKILL.md; then pass "Multi-perspective query pattern named"; else fail "Multi-perspective not named"; fi

echo ""
echo "== Allowed-tools discipline =="
if have "allowed-tools" SKILL.md; then pass "allowed-tools frontmatter present"; else fail "allowed-tools missing"; fi

echo ""
echo "== README + LICENSE =="
[ -f README.md ] && pass "README.md present" || fail "README.md missing"
[ -f LICENSE ] && pass "LICENSE present" || fail "LICENSE missing"

echo ""
echo "======================================"
echo "  PASS: $PASS    FAIL: $FAIL"
echo "======================================"
if [ "$FAIL" -eq 0 ]; then exit 0; else exit 1; fi
