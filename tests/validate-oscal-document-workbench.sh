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
  fetch-oscal-baseline
  draft-ssp-from-extraction
  ksi-coverage
  validate-oscal-package
  update-ssp-from-evidence
)

required_scripts=(
  extract-legacy-doc.sh
  bootstrap-trestle-workspace.sh
  fetch-oscal-baseline.sh
  fetch-fedramp-2026-rules.sh
  draft-ssp-from-extraction.sh
  ksi-coverage-report.sh
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
for (const command of ['ingest-ssp','extract-legacy-doc','build-trestle-workspace','fetch-oscal-baseline','draft-ssp-from-extraction','ksi-coverage','validate-oscal-package','update-ssp-from-evidence']) {
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
python3 -m py_compile "$plugin_root/scripts/draft-ssp-from-extraction.py"
python3 -m py_compile "$plugin_root/scripts/ksi-coverage-report.py"

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

[[ -f "$plugin_root/templates/fedramp-rev5-heading-map.json" ]] || { echo "missing FedRAMP heading map template" >&2; exit 1; }
grep -q 'draft-ssp-from-extraction' "$plugin_root/commands/ingest-ssp.md" || { echo "ingest-ssp must document draft script" >&2; exit 1; }

grep -q 'sed -i "1i' "$plugin_root/scripts/extract-legacy-doc.sh" && {
  echo "extract-legacy-doc.sh still uses GNU sed -i insert syntax" >&2
  exit 1
}

grep -q -- '--allow-partial' "$plugin_root/scripts/validate-oscal-package.sh" || {
  echo "validate-oscal-package.sh must support --allow-partial" >&2
  exit 1
}

summarize_dir="$(mktemp -d)"
cat > "$summarize_dir/source-map.csv" <<'CSV'
source_id,source_file,page_or_section,heading,extracted_text_hash,oscal_target,status,notes
SRC-001,sample.md,1,"Services, Ports, and Protocols",sha256:abc,system-implementation.components,mapped,ok
SRC-002,sample.md,2,Open Items,sha256:def,back-matter.resources,needs_review,gap
CSV
set +e
node "$plugin_root/scripts/summarize-source-map.js" "$summarize_dir/source-map.csv" >"$summarize_dir/summary.json"
summary_code=$?
set -e
[[ "$summary_code" -eq 3 ]] || { echo "summarize-source-map.js should exit 3 when needs_review remains" >&2; exit 1; }
python3 - "$summarize_dir/summary.json" <<'PY'
import json, sys
summary = json.load(open(sys.argv[1], encoding="utf-8"))
assert summary["total"] == 2, summary
assert summary["counts"]["mapped"] == 1 and summary["counts"]["needs_review"] == 1, summary
PY
rm -rf "$summarize_dir"

echo "OSCAL Document Workbench plugin surface is valid."
