#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$repo_root"

example_root="examples/legacy-ssp-to-oscal"
workspace="$example_root/workspace/basic-demo"
rm -rf "$workspace"
mkdir -p "$workspace/reports"

bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh \
  "$example_root/input/sample-ssp.md" \
  --output "$workspace/extracted"

bash plugins/document-transform/oscal-document-workbench/scripts/bootstrap-trestle-workspace.sh \
  "$workspace" \
  --profile synthetic-nist-800-53-demo \
  --oscal-version 1.1.3

if command -v trestle >/dev/null 2>&1; then
  bash plugins/document-transform/oscal-document-workbench/scripts/draft-ssp-from-extraction.sh \
    "$workspace" \
    --profile-label synthetic-nist-800-53-demo \
    --overwrite
else
  cp "$example_root/input/source-map.csv" "$workspace/extracted/source-map.csv"
  printf 'Compliance Trestle is not installed. Copied static source-map.csv. Did not draft an SSP.\n' >&2
fi

set +e
node plugins/document-transform/oscal-document-workbench/scripts/summarize-source-map.js \
  "$workspace/extracted/source-map.csv" > "$workspace/reports/source-map-summary.json"
summary_code=$?
set -e
if [[ "$summary_code" -ne 0 && "$summary_code" -ne 3 ]]; then
  printf 'summarize-source-map.js failed with exit %s\n' "$summary_code" >&2
  exit "$summary_code"
fi

printf 'Legacy SSP to OSCAL example generated at %s\n' "$workspace"
