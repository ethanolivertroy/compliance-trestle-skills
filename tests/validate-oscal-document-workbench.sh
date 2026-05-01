#!/usr/bin/env bash
# Validate OSCAL Document Workbench plugin surface and scripts.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_root="plugins/document-transform/oscal-document-workbench"
manifest="$plugin_root/.claude-plugin/plugin.json"
marketplace=".claude-plugin/marketplace.json"

required_commands=(
  ingest-ssp
  extract-legacy-doc
  build-trestle-workspace
  validate-oscal-package
  update-ssp-from-evidence
)

required_scripts=(
  extract-legacy-doc.sh
  bootstrap-trestle-workspace.sh
  validate-oscal-package.sh
  summarize-source-map.js
)

[[ -f "$manifest" ]] || { echo "missing $manifest" >&2; exit 1; }
[[ -f "$plugin_root/README.md" ]] || { echo "missing plugin README" >&2; exit 1; }
[[ -f "$plugin_root/skills/oscal-document-workbench-expert/SKILL.md" ]] || { echo "missing workbench skill" >&2; exit 1; }

node <<'NODE'
const fs = require('fs');
const manifest = JSON.parse(fs.readFileSync('plugins/document-transform/oscal-document-workbench/.claude-plugin/plugin.json', 'utf8'));
if (manifest.name !== 'oscal-document-workbench') throw new Error(`unexpected plugin name: ${manifest.name}`);
const marketplace = JSON.parse(fs.readFileSync('.claude-plugin/marketplace.json', 'utf8'));
const entry = marketplace.plugins.find((plugin) => plugin.name === 'oscal-document-workbench');
if (!entry) throw new Error('oscal-document-workbench is not registered in marketplace.json');
if (entry.source !== './plugins/document-transform/oscal-document-workbench') throw new Error(`unexpected source: ${entry.source}`);
for (const command of ['ingest-ssp','extract-legacy-doc','build-trestle-workspace','validate-oscal-package','update-ssp-from-evidence']) {
  if (!entry.commands.includes(command)) throw new Error(`marketplace entry missing command ${command}`);
}
NODE

for command in "${required_commands[@]}"; do
  file="$plugin_root/commands/$command.md"
  [[ -f "$file" ]] || { echo "missing command $file" >&2; exit 1; }
  grep -q '^---$' "$file" || { echo "command missing frontmatter fence: $file" >&2; exit 1; }
  grep -q '^description:' "$file" || { echo "command missing description: $file" >&2; exit 1; }
  grep -q '## How to run' "$file" || { echo "command missing How to run: $file" >&2; exit 1; }
  grep -q '## Exit codes' "$file" || { echo "command missing Exit codes: $file" >&2; exit 1; }
  grep -q 'needs_review' "$file" || { echo "command must mention needs_review guardrail: $file" >&2; exit 1; }
done

for script in "${required_scripts[@]}"; do
  file="$plugin_root/scripts/$script"
  [[ -f "$file" ]] || { echo "missing script $file" >&2; exit 1; }
  [[ -x "$file" ]] || { echo "script is not executable: $file" >&2; exit 1; }
  case "$script" in
    *.sh) bash -n "$file" ;;
    *.js) node --check "$file" ;;
  esac
done

skill="$plugin_root/skills/oscal-document-workbench-expert/SKILL.md"
grep -q '^name:' "$skill" || { echo "skill missing name" >&2; exit 1; }
grep -q '^description:' "$skill" || { echo "skill missing description" >&2; exit 1; }
grep -q 'Compliance Trestle' "$skill" || { echo "skill must mention Compliance Trestle" >&2; exit 1; }
grep -q 'source traceability' "$skill" || { echo "skill must mention source traceability" >&2; exit 1; }

[[ -f "$plugin_root/templates/source-map.csv" ]] || { echo "missing source-map template" >&2; exit 1; }
grep -q '^source_id,source_file,page_or_section,heading,extracted_text_hash,oscal_target,status,notes$' "$plugin_root/templates/source-map.csv" || {
  echo "source-map template header is incorrect" >&2
  exit 1
}

echo "OSCAL Document Workbench plugin surface is valid."
