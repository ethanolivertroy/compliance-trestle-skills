#!/usr/bin/env bash
# Validate draft SSP from extraction script and FedRAMP heading templates.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

plugin_root="plugins/document-transform/oscal-document-workbench"
script_sh="$plugin_root/scripts/draft-ssp-from-extraction.sh"
script_py="$plugin_root/scripts/draft-ssp-from-extraction.py"
baseline_sh="$plugin_root/scripts/fetch-oscal-baseline.sh"
map_json="$plugin_root/templates/fedramp-rev5-heading-map.json"
map_md="$plugin_root/templates/fedramp-rev5-ssp-section-map.md"

for file in "$script_sh" "$script_py" "$baseline_sh" "$map_json" "$map_md"; do
  [[ -f "$file" ]] || { echo "missing $file" >&2; exit 1; }
done

[[ -x "$script_sh" ]] || { echo "script is not executable: $script_sh" >&2; exit 1; }
[[ -x "$baseline_sh" ]] || { echo "script is not executable: $baseline_sh" >&2; exit 1; }
bash -n "$script_sh"
bash -n "$baseline_sh"
python3 -m py_compile "$script_py"
grep -q 'baseline-profile' "$script_sh" || { echo "draft script must support --baseline-profile" >&2; exit 1; }
grep -q 'fedramp-resources' "$baseline_sh" || { echo "baseline script must reference FedRAMP OSCAL source" >&2; exit 1; }
[[ -f "$plugin_root/commands/fetch-oscal-baseline.md" ]] || { echo "missing fetch-oscal-baseline command doc" >&2; exit 1; }

# Regression checks against real FedRAMP legacy template headings
# (headings from the legacy FedRAMP SSP template and Appendix A at
# https://www.fedramp.gov/legacy/, mirrored in FedRAMP/docs-legacy on GitHub).
python3 - "$plugin_root" <<'PY'
import importlib.util
import json
import re
import sys
from pathlib import Path

plugin_root = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location(
    "draft_ssp", plugin_root / "scripts" / "draft-ssp-from-extraction.py"
)
mod = importlib.util.module_from_spec(spec)
sys.modules["draft_ssp"] = mod
spec.loader.exec_module(mod)

# Control ID normalization must match OSCAL catalog IDs
cases = {
    "AC-2": "ac-2",
    "AC-2(1)": "ac-2.1",
    "AC-2(12)": "ac-2.12",
    "AC-2 (1)": "ac-2.1",
    "AU-2(3)(a)": "au-2.3.a",
    "SC-13": "sc-13",
    "IA-5.1": "ia-5.1",
}
for raw, expected in cases.items():
    got = mod.normalize_control_id(raw.lower())
    assert got == expected, f"normalize_control_id({raw}) = {got}, expected {expected}"

# Real Appendix A heading style must be detected as a control heading
appendix_headings = [
    "AC-1 Policy and Procedures (L)(M)(H)",
    "AC-2(12) Account Monitoring for Atypical Usage (M)(H)",
    "SC-13 Cryptographic Protection (L)(M)(H)",
]
for heading in appendix_headings:
    assert mod.CONTROL_HEADING_RE.match(heading), f"control heading not detected: {heading}"

# Real legacy SSP template section headings must all match a mapping rule
rules = json.loads((plugin_root / "templates" / "fedramp-rev5-heading-map.json").read_text())
patterns = [re.compile(r["pattern"], re.IGNORECASE) for r in rules["section_rules"]]
template_headings = [
    "Introduction",
    "Purpose",
    "System Information",
    "System Owner",
    "Assignment of Security Responsibility",
    "Leveraged FedRAMP-Authorized Services",
    "External Systems and Services Not Having FedRAMP Authorization",
    "Illustrated Architecture",
    "Narrative",
    "Services, Ports, and Protocols",
    "Separation of Duties",
    "SSP Appendices List",
]
unmatched = [h for h in template_headings if not any(p.search(h) for p in patterns)]
assert not unmatched, f"legacy FedRAMP template headings without mapping rules: {unmatched}"
target_by_heading = {
    "Users": "system-security-plan.system-implementation.users",
    "System Environment": "system-security-plan.system-characteristics.network-architecture.description",
}
for heading, expected in target_by_heading.items():
    match = next(
        (rule["oscal_target"] for rule, pattern in zip(rules["section_rules"], patterns) if pattern.search(heading)),
        None,
    )
    assert match == expected, f"{heading} mapped to {match}, expected {expected}"
print("FedRAMP legacy template heading regression checks passed.")
PY

grep -q 'fedramp.gov/rev5/documents-templates' "$map_json" || { echo "heading map must reference FedRAMP templates URL" >&2; exit 1; }
grep -q 'needs_review' "$map_md" || { echo "section map must mention needs_review" >&2; exit 1; }
grep -q 'draft-ssp-from-extraction' "$plugin_root/commands/ingest-ssp.md" || { echo "ingest-ssp must document draft script" >&2; exit 1; }

if command -v trestle >/dev/null 2>&1; then
  workdir="$(mktemp -d)"
  # Canonicalize so paths match Trestle's resolved workspace root
  # (macOS mktemp returns /var/folders/..., a symlink to /private/var/folders/...).
  workdir="$(cd "$workdir" && pwd -P)"
  trap 'rm -rf "$workdir"' EXIT
  cp examples/legacy-ssp-to-oscal/input/sample-ssp.md "$workdir/input.md"
  bash "$plugin_root/scripts/extract-legacy-doc.sh" "$workdir/input.md" --output "$workdir/extracted"
  bash "$plugin_root/scripts/bootstrap-trestle-workspace.sh" "$workdir" --profile fedramp-moderate --overwrite
  bash "$script_sh" "$workdir" --overwrite
  [[ -f "$workdir/reports/draft-summary.md" ]] || { echo "missing draft-summary.md after integration run" >&2; exit 1; }
  python3 - "$workdir" <<'PY'
import json, sys
from pathlib import Path
workspace = Path(sys.argv[1])
ssp_file = next(workspace.joinpath("trestle-workspace/system-security-plans").rglob("system-security-plan.json"))
ssp = json.loads(ssp_file.read_text(encoding="utf-8"))
prose = ssp["system-security-plan"]["system-characteristics"]["description"]
assert "No real customer data is included in this example." in prose, prose
assert len(prose) > 240, len(prose)
PY
  ssp_file="$(find "$workdir/trestle-workspace/system-security-plans" -name system-security-plan.json | head -1)"
  [[ -n "$ssp_file" ]] || { echo "missing drafted SSP JSON" >&2; exit 1; }
  (cd "$workdir/trestle-workspace" && trestle validate -f "$ssp_file") >/dev/null
  echo "Draft SSP integration test passed."

  if command -v oscal-cli >/dev/null 2>&1; then
    # Constraint validation is disabled because trestle:// hrefs are internal.
    for oscal_file in \
      "$ssp_file" \
      "$(find "$workdir/trestle-workspace/catalogs" -name catalog.json | head -1)" \
      "$(find "$workdir/trestle-workspace/profiles" -name profile.json | head -1)"; do
      [[ -n "$oscal_file" ]] || { echo "missing generated OSCAL model file" >&2; exit 1; }
      oscal-cli validate --disable-constraint-validation --quiet --no-color "$oscal_file" \
        || { echo "oscal-cli schema validation failed: $oscal_file" >&2; exit 1; }
    done
    echo "oscal-cli schema validation passed for drafted catalog, profile, and SSP."
  else
    echo "oscal-cli not installed; skipped NIST schema validation."
  fi

  # KSI coverage integration: skip gracefully when the rules download is unavailable.
  if bash "$plugin_root/scripts/fetch-fedramp-2026-rules.sh" >/dev/null 2>&1; then
    bash "$plugin_root/scripts/ksi-coverage-report.sh" "$ssp_file" \
      --output "$workdir/reports/ksi-coverage.md" \
      --json-output "$workdir/reports/ksi-coverage.json" >/dev/null
    [[ -f "$workdir/reports/ksi-coverage.md" ]] || { echo "missing ksi-coverage.md" >&2; exit 1; }
    python3 -c "
import json
report = json.load(open('$workdir/reports/ksi-coverage.json'))
assert report['totals']['covered'] + report['totals']['partial'] + report['totals']['uncovered'] > 0
" || { echo "ksi coverage JSON is empty" >&2; exit 1; }
    echo "KSI coverage integration test passed."
  else
    echo "KSI coverage integration skipped (FedRAMP 2026 rules download unavailable)."
  fi
else
  echo "Draft SSP static checks passed (Trestle not installed; skipped integration run)."
fi
