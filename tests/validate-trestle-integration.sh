#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
skill="agent-skills/compliance-trestle-engineering/SKILL.md"
[[ -f "$skill" ]] || { echo "missing $skill" >&2; exit 1; }
for required in "source traceability" "needs_review" "Compliance Trestle" "trestle validate"; do
  grep -qi "$required" "$skill" || { echo "missing '$required' in $skill" >&2; exit 1; }
done
[[ -f agent-skills/compliance-trestle-engineering/references/trestle-workspace-lifecycle.md ]] || exit 1
[[ -f agent-skills/compliance-trestle-engineering/references/trestle-oscal-operations.md ]] || exit 1
[[ -f agent-skills/compliance-trestle-engineering/templates/trestle-workflow-checklist.md ]] || exit 1
[[ -x scripts/trestle-workflow.sh ]] || { echo "scripts/trestle-workflow.sh must be executable" >&2; exit 1; }
bash -n scripts/trestle-workflow.sh
node <<'NODE'
const fs = require('fs');
const manifest = JSON.parse(fs.readFileSync('agent-skills/manifest.json','utf8'));
if (!manifest.skills.some(s => s.name === 'compliance-trestle-engineering')) throw new Error('manifest missing compliance-trestle-engineering');
NODE
echo "Compliance Trestle integration is valid."
