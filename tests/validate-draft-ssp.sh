#!/usr/bin/env bash
# Validate draft SSP from extraction script and FedRAMP heading templates.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_root="plugins/document-transform/oscal-document-workbench"
script_sh="$plugin_root/scripts/draft-ssp-from-extraction.sh"
script_py="$plugin_root/scripts/draft-ssp-from-extraction.py"
map_json="$plugin_root/templates/fedramp-rev5-heading-map.json"
map_md="$plugin_root/templates/fedramp-rev5-ssp-section-map.md"

for file in "$script_sh" "$script_py" "$map_json" "$map_md"; do
  [[ -f "$file" ]] || { echo "missing $file" >&2; exit 1; }
done

[[ -x "$script_sh" ]] || { echo "script is not executable: $script_sh" >&2; exit 1; }
bash -n "$script_sh"
python3 -m py_compile "$script_py"

grep -q 'fedramp.gov/rev5/documents-templates' "$map_json" || { echo "heading map must reference FedRAMP templates URL" >&2; exit 1; }
grep -q 'needs_review' "$map_md" || { echo "section map must mention needs_review" >&2; exit 1; }
grep -q 'draft-ssp-from-extraction' "$plugin_root/commands/ingest-ssp.md" || { echo "ingest-ssp must document draft script" >&2; exit 1; }

if command -v trestle >/dev/null 2>&1; then
  workdir="$(mktemp -d)"
  trap 'rm -rf "$workdir"' EXIT
  cp examples/legacy-ssp-to-oscal/input/sample-ssp.md "$workdir/input.md"
  bash "$plugin_root/scripts/extract-legacy-doc.sh" "$workdir/input.md" --output "$workdir/extracted"
  bash "$plugin_root/scripts/bootstrap-trestle-workspace.sh" "$workdir" --profile fedramp-moderate --overwrite
  bash "$script_sh" "$workdir" --overwrite
  [[ -f "$workdir/reports/draft-summary.md" ]] || { echo "missing draft-summary.md after integration run" >&2; exit 1; }
  ssp_file="$(find "$workdir/trestle-workspace/system-security-plans" -name system-security-plan.json | head -1)"
  [[ -n "$ssp_file" ]] || { echo "missing drafted SSP JSON" >&2; exit 1; }
  (cd "$workdir/trestle-workspace" && trestle validate -f "$ssp_file") >/dev/null
  echo "Draft SSP integration test passed."
else
  echo "Draft SSP static checks passed (Trestle not installed; skipped integration run)."
fi
