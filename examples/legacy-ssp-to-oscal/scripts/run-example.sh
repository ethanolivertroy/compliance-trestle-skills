#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$repo_root"

example_root="examples/legacy-ssp-to-oscal"
workspace="$example_root/workspace"
rm -rf "$workspace"
mkdir -p "$workspace"

bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh \
  "$example_root/input/sample-ssp.md" \
  --output "$workspace/extracted"

bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh \
  "$workspace" \
  --profile synthetic-nist-800-53-demo \
  --oscal-version 1.1.3

cp "$example_root/input/source-map.csv" "$workspace/extracted/source-map.csv"
node plugins/document-transform/oscal-document-workbench/scripts/summarize-source-map.js \
  "$workspace/extracted/source-map.csv" > "$workspace/reports/source-map-summary.json" || true

echo "Legacy SSP to OSCAL example generated at $workspace"
