#!/usr/bin/env bash
set -euo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
plugin_root="plugins/document-transform/oscal-document-workbench"
[[ -f docs/OSCAL-REVIEW-WORKFLOW.md ]] || { echo "missing review workflow doc" >&2; exit 1; }
[[ -x "$plugin_root/scripts/build-review-queue.sh" ]] || { echo "missing executable review queue script" >&2; exit 1; }
bash -n "$plugin_root/scripts/build-review-queue.sh"
for f in "$plugin_root/templates/review-queue.md" "$plugin_root/templates/control-mapping-review.csv" "$plugin_root/templates/oscal-ssp-system-characteristics.md" "$plugin_root/templates/oscal-ssp-control-implementation.md" "$plugin_root/templates/oscal-ssp-parties-components.md"; do
  [[ -f "$f" ]] || { echo "missing $f" >&2; exit 1; }
done
grep -q "schema-valid OSCAL does not prove compliance effectiveness" docs/OSCAL-REVIEW-WORKFLOW.md || { echo "missing compliance effectiveness warning" >&2; exit 1; }
workdir="$(mktemp -d)"
trap 'rm -rf "$workdir"' EXIT
cat > "$workdir/source-map.csv" <<'CSV'
source_id,source_file,page_or_section,heading,extracted_text_hash,oscal_target,status,notes
SRC-001,sample.md,1,Access Control,sha256:abc,,needs_review,ambiguous mapping
CSV
set +e
bash "$plugin_root/scripts/build-review-queue.sh" "$workdir/source-map.csv" "$workdir/review-queue.md" >/tmp/review-queue-test.log 2>&1
code=$?
set -e
[[ "$code" -eq 1 ]] || { echo "review queue should exit 1 when review items remain" >&2; cat /tmp/review-queue-test.log >&2; exit 1; }
grep -q "SRC-001" "$workdir/review-queue.md" || { echo "review queue missing source row" >&2; exit 1; }
echo "OSCAL review workflow is valid."
