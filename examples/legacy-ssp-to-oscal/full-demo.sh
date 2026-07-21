#!/usr/bin/env bash
# End-to-end synthetic legacy SSP to OSCAL/Trestle workbench demo.
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"
example_root="examples/legacy-ssp-to-oscal"
workspace="$example_root/workspace/full-demo"
rm -rf "$workspace"
mkdir -p "$workspace"

bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh \
  "$example_root/input/sample-ssp.md" \
  --output "$workspace/extracted"

bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh \
  "$workspace" \
  --profile fedramp-moderate

draft_code=0
validation_status="not-run"
if command -v trestle >/dev/null 2>&1; then
  bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh \
    "$workspace" \
    --profile-label fedramp-moderate \
    --overwrite
  draft_code=$?
  bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh \
    "$workspace/trestle-workspace" \
    --output "$workspace/reports/validation-report.json"
  validation_status="$(node -pe "JSON.parse(require('fs').readFileSync('$workspace/reports/validation-report.json','utf8')).status")"
else
  echo "Compliance Trestle not installed; skipping draft SSP and validation steps." >&2
  draft_code=5
  validation_status="skipped-missing-trestle"
fi

set +e
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh \
  "$workspace/extracted/source-map.csv" \
  "$workspace/reports/review-queue.md"
review_code=$?
set -e

cat > "$workspace/reports/demo-summary.md" <<EOF
# Legacy SSP to OSCAL demo summary

- Extracted markdown: $workspace/extracted/extracted.md
- Source map: $workspace/extracted/source-map.csv
- Sections JSON: $workspace/extracted/sections.json
- Trestle workspace: $workspace/trestle-workspace
- Draft summary: $workspace/reports/draft-summary.md
- Review queue: $workspace/reports/review-queue.md
- Validation report: $workspace/reports/validation-report.json
- Draft SSP exit code: $draft_code
- Review queue exit code: $review_code
- Validation status: $validation_status

When Trestle is installed, this demo drafts a schema-valid OSCAL SSP from extracted legacy sections using FedRAMP Rev 5 heading conventions.
Schema-valid OSCAL does not prove compliance effectiveness.
EOF

echo "Demo complete: $workspace/reports/demo-summary.md"
