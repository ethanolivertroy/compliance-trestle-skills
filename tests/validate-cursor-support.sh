#!/usr/bin/env bash
# Validate native Cursor support artifacts.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  CURSOR.md
  adapters/cursor/README.md
  .cursor/rules/compliance-trestle.mdc
  .cursor/rules/oscal-workspace-guardrails.mdc
  .cursor/rules/oscal-json-edit.mdc
)

for file in "${required_files[@]}"; do
  [[ -f "$file" ]] || { echo "missing $file" >&2; exit 1; }
done

required_skills=(
  oscal-document-engineering
  compliance-trestle-engineering
  import-legacy-ssp
  validate-oscal-package
  review-oscal-mappings
  workspace-validate
)

for skill in "${required_skills[@]}"; do
  file=".cursor/skills/$skill/SKILL.md"
  [[ -e "$file" ]] || { echo "missing Cursor skill $file" >&2; exit 1; }
  grep -q '^name:' "$file" || { echo "Cursor skill missing name: $file" >&2; exit 1; }
  grep -q '^description:' "$file" || { echo "Cursor skill missing description: $file" >&2; exit 1; }
done

grep -q 'Cursor' CURSOR.md || { echo "CURSOR.md must mention Cursor" >&2; exit 1; }
grep -q '.cursor/skills/' CURSOR.md || { echo "CURSOR.md must document .cursor/skills/" >&2; exit 1; }
grep -q 'import-legacy-ssp' CURSOR.md || { echo "CURSOR.md must document import-legacy-ssp skill" >&2; exit 1; }
grep -q 'needs_review' CURSOR.md || { echo "CURSOR.md must require needs_review handling" >&2; exit 1; }
grep -q 'source traceability' CURSOR.md || { echo "CURSOR.md must require source traceability" >&2; exit 1; }

grep -q '.cursor/skills/' adapters/cursor/README.md || { echo "Cursor adapter README must mention .cursor/skills/" >&2; exit 1; }
grep -q '/import-legacy-ssp' adapters/cursor/README.md || { echo "Cursor adapter README must document /import-legacy-ssp" >&2; exit 1; }

grep -q 'CURSOR.md' .cursor/rules/compliance-trestle.mdc || { echo "Cursor rule must point to CURSOR.md" >&2; exit 1; }
grep -q '.cursor/skills/' .cursor/rules/compliance-trestle.mdc || { echo "Cursor rule must mention project skills" >&2; exit 1; }

grep -q 'needs_review' .cursor/rules/oscal-workspace-guardrails.mdc || { echo "workspace guardrails must mention needs_review" >&2; exit 1; }
grep -q 'trestle validate' .cursor/rules/oscal-json-edit.mdc || { echo "oscal json edit rule must recommend validation" >&2; exit 1; }

for skill in import-legacy-ssp validate-oscal-package review-oscal-mappings workspace-validate; do
  file=".cursor/skills/$skill/SKILL.md"
  grep -q 'disable-model-invocation: true' "$file" || { echo "workflow skill must disable model invocation: $file" >&2; exit 1; }
done

node <<'NODE'
const fs = require('fs');
const path = require('path');

function readSkill(skillPath) {
  const content = fs.readFileSync(skillPath, 'utf8');
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) throw new Error(`missing frontmatter: ${skillPath}`);
  const name = match[1].match(/^name:\s*(.+)$/m)?.[1]?.trim();
  const folder = path.basename(path.dirname(skillPath));
  if (!name) throw new Error(`missing name in ${skillPath}`);
  if (name !== folder) throw new Error(`skill name ${name} must match folder ${folder} in ${skillPath}`);
}

for (const skill of [
  'import-legacy-ssp',
  'validate-oscal-package',
  'review-oscal-mappings',
  'workspace-validate',
  'oscal-document-engineering',
  'compliance-trestle-engineering',
]) {
  readSkill(`.cursor/skills/${skill}/SKILL.md`);
}
NODE

echo "Native Cursor support is valid."
