#!/usr/bin/env bash
# Validate generic agent instruction and compatibility docs.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  AGENTS.md
  GEMINI.md
  OPENCODE.md
  .cursor/rules/compliance-trestle.mdc
  .windsurf/rules/compliance-trestle.md
  docs/AGENT-COMPATIBILITY.md
  docs/PORTABLE-SKILLS.md
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "missing $file" >&2; exit 1; }
done

grep -q 'agent-portable' AGENTS.md || { echo "AGENTS.md must describe agent-portable usage" >&2; exit 1; }
grep -q 'agent-skills/oscal-document-engineering/SKILL.md' AGENTS.md || { echo "AGENTS.md must link OSCAL skill" >&2; exit 1; }
grep -q 'source traceability' AGENTS.md || { echo "AGENTS.md must require source traceability" >&2; exit 1; }
grep -q 'needs_review' AGENTS.md || { echo "AGENTS.md must require needs_review" >&2; exit 1; }

grep -q 'Gemini CLI' GEMINI.md || { echo "GEMINI.md must mention Gemini CLI" >&2; exit 1; }
grep -q 'OpenCode' OPENCODE.md || { echo "OPENCODE.md must mention OpenCode" >&2; exit 1; }
grep -q 'Claude Code' docs/AGENT-COMPATIBILITY.md || { echo "compatibility doc missing Claude Code" >&2; exit 1; }
grep -q 'OpenAI Codex CLI' docs/AGENT-COMPATIBILITY.md || { echo "compatibility doc missing Codex CLI" >&2; exit 1; }
grep -q 'Gemini CLI' docs/AGENT-COMPATIBILITY.md || { echo "compatibility doc missing Gemini CLI" >&2; exit 1; }
grep -q 'OpenCode' docs/AGENT-COMPATIBILITY.md || { echo "compatibility doc missing OpenCode" >&2; exit 1; }
grep -q 'Generic desktop agent app' docs/AGENT-COMPATIBILITY.md || { echo "compatibility doc missing generic desktop app" >&2; exit 1; }

grep -q 'agent-skills/' docs/PORTABLE-SKILLS.md || { echo "portable skills doc must define agent-skills directory" >&2; exit 1; }
grep -q 'name:' docs/PORTABLE-SKILLS.md || { echo "portable skills doc must show required frontmatter" >&2; exit 1; }
grep -q 'description:' docs/PORTABLE-SKILLS.md || { echo "portable skills doc must show description frontmatter" >&2; exit 1; }

echo "Agent adapter docs are valid."
