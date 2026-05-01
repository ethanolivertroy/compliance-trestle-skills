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

set +e
bash plugins/document-transform/oscal-document-workbench/scripts/build-review-queue.sh \
  "$workspace/extracted/source-map.csv" \
  "$workspace/reports/review-queue.md"
review_code=$?
set -e

bash plugins/document-transform/oscal-document-workbench/scripts/validate-oscal-package.sh \
  "$workspace/trestle-workspace" \
  --output "$workspace/reports/validation-report.json"

cat > "$workspace/reports/demo-summary.md" <<EOF
# Legacy SSP to OSCAL demo summary

- Extracted markdown: $workspace/extracted/extracted.md
- Source map: $workspace/extracted/source-map.csv
- Sections JSON: $workspace/extracted/sections.json
- Trestle workspace: $workspace/trestle-workspace
- Review queue: $workspace/reports/review-queue.md
- Validation report: $workspace/reports/validation-report.json
- Review queue exit code: $review_code

The review queue exit code is expected to be nonzero while pending mappings remain.
Schema-valid OSCAL does not prove compliance effectiveness.
EOF

echo "Demo complete: $workspace/reports/demo-summary.md"
