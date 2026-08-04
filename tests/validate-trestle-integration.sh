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
node <<'NODE'
const fs = require('fs');
const version = JSON.parse(fs.readFileSync('package.json', 'utf8')).version;
const paths = [
  'agent-skills/manifest.json',
  '.claude-plugin/marketplace.json',
  '.claude-plugin/plugin.json',
  'adapters/generic-agent-package/manifest.agent.json',
  'plugins/document-transform/oscal-document-workbench/.claude-plugin/plugin.json',
];
for (const file of paths) {
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  const found = data.version || data.metadata?.version;
  if (found !== version) throw new Error(`${file} version ${found} != ${version}`);
}
NODE

missing_dir="$(mktemp -d)"
set +e
PATH="/usr/bin:/bin" bash scripts/trestle-workflow.sh validate "$missing_dir" >/dev/null 2>&1
code=$?
set -e
[[ "$code" -eq 5 ]] || { echo "trestle-workflow validate without trestle should exit 5, got $code" >&2; exit 1; }
rm -rf "$missing_dir"

grep -Eq 'trestle-workflow.sh assemble .+ acme-ssp' agent-skills/compliance-trestle-engineering/SKILL.md || {
  echo "compliance-trestle-engineering assemble example must pass an output SSP name" >&2
  exit 1
}

echo "Compliance Trestle integration is valid."
