#!/usr/bin/env bash
# Validate portable agent skill package surface.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

manifest="agent-skills/manifest.json"
[[ -f "$manifest" ]] || { echo "missing $manifest" >&2; exit 1; }
[[ -f "agent-skills/README.md" ]] || { echo "missing agent-skills/README.md" >&2; exit 1; }

node <<'NODE'
const fs = require('fs');
const manifest = JSON.parse(fs.readFileSync('agent-skills/manifest.json', 'utf8'));
if (manifest.name !== 'compliance-trestle-agent-skills') throw new Error(`unexpected manifest name: ${manifest.name}`);
if (!Array.isArray(manifest.skills) || manifest.skills.length === 0) throw new Error('manifest.skills must be a non-empty array');
for (const skill of manifest.skills) {
  for (const field of ['name', 'path', 'description']) {
    if (!skill[field]) throw new Error(`skill missing ${field}: ${JSON.stringify(skill)}`);
  }
  const skillPath = `agent-skills/${skill.path.replace(/^\.\//, '')}/SKILL.md`;
  if (!fs.existsSync(skillPath)) throw new Error(`missing skill file: ${skillPath}`);
}
NODE

required_skills=(
  oscal-document-engineering
  compliance-trestle-engineering
)

for skill in "${required_skills[@]}"; do
  file="agent-skills/$skill/SKILL.md"
  [[ -f "$file" ]] || { echo "missing skill $file" >&2; exit 1; }
  grep -q '^---$' "$file" || { echo "skill missing frontmatter fence: $file" >&2; exit 1; }
  grep -q '^name:' "$file" || { echo "skill missing name: $file" >&2; exit 1; }
  grep -q '^description:' "$file" || { echo "skill missing description: $file" >&2; exit 1; }
  grep -qi 'source traceability' "$file" || { echo "skill must require source traceability: $file" >&2; exit 1; }
  grep -qi 'needs_review' "$file" || { echo "skill must require needs_review handling: $file" >&2; exit 1; }
  grep -qi 'Compliance Trestle' "$file" || { echo "skill must reference Compliance Trestle: $file" >&2; exit 1; }

done

[[ -f agent-skills/oscal-document-engineering/references/legacy-doc-ingestion.md ]] || { echo "missing legacy doc ingestion reference" >&2; exit 1; }
[[ -f agent-skills/oscal-document-engineering/references/oscal-validation.md ]] || { echo "missing OSCAL validation reference" >&2; exit 1; }
[[ -f agent-skills/oscal-document-engineering/templates/ssp-import-plan.md ]] || { echo "missing SSP import plan template" >&2; exit 1; }
[[ -f agent-skills/oscal-document-engineering/templates/source-traceability-map.csv ]] || { echo "missing source traceability map template" >&2; exit 1; }

grep -q '^source_id,source_file,page_or_section,heading,extracted_text_hash,oscal_target,status,notes$' \
  agent-skills/oscal-document-engineering/templates/source-traceability-map.csv || {
    echo "source traceability map header is incorrect" >&2
    exit 1
  }

echo "Portable agent skills are valid."
