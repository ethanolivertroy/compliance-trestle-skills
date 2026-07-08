#!/usr/bin/env bash
# Fetch the NIST 800-53 Rev 5 catalog and a FedRAMP Rev 5 baseline profile,
# then import both into a Compliance Trestle workspace.
set -euo pipefail

SOURCE="oscal-document-workbench:fetch-oscal-baseline"
NIST_CATALOG_URL="${OSCAL_NIST_CATALOG_URL:-https://raw.githubusercontent.com/usnistgov/oscal-content/main/nist.gov/SP800-53/rev5/json/NIST_SP-800-53_rev5_catalog.json}"
FEDRAMP_BASE_URL="${OSCAL_FEDRAMP_BASE_URL:-https://raw.githubusercontent.com/OSCAL-Foundation/fedramp-resources/main/baselines/rev5/json}"

WORKSPACE=""
BASELINE="moderate"
CACHE_DIR="${OSCAL_BASELINE_CACHE:-$HOME/.cache/oscal-baselines}"
CATALOG_ALIAS="nist-800-53-rev5"
OVERWRITE=0
SKIP_VALIDATE=0

usage() {
  cat <<'EOF'
Usage: fetch-oscal-baseline.sh <trestle-workspace> [--baseline low|moderate|high|li-saas] [--cache-dir <dir>] [--overwrite] [--skip-validate]

Downloads the NIST SP 800-53 Rev 5 OSCAL catalog and the requested FedRAMP Rev 5
baseline profile, caches them locally, and imports both into the given
Compliance Trestle workspace as:

  catalogs/nist-800-53-rev5
  profiles/fedramp-rev5-<baseline>

Sources:
  NIST catalog:     usnistgov/oscal-content (raw.githubusercontent.com)
  FedRAMP profiles: OSCAL-Foundation/fedramp-resources (raw.githubusercontent.com)

Exit codes: 0 success, 2 bad arguments, 3 import/validation failure, 5 missing dependency or download failure.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --baseline) shift; BASELINE="${1:-}" ;;
    --baseline=*) BASELINE="${1#*=}" ;;
    --cache-dir) shift; CACHE_DIR="${1:-}" ;;
    --cache-dir=*) CACHE_DIR="${1#*=}" ;;
    --overwrite) OVERWRITE=1 ;;
    --skip-validate) SKIP_VALIDATE=1 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "[$SOURCE] unknown flag: $1" >&2; exit 2 ;;
    *) if [[ -z "$WORKSPACE" ]]; then WORKSPACE="$1"; else echo "[$SOURCE] unexpected argument: $1" >&2; exit 2; fi ;;
  esac
  shift || true
done

[[ -n "$WORKSPACE" ]] || { usage >&2; exit 2; }
[[ -d "$WORKSPACE/.trestle" ]] || { echo "[$SOURCE] $WORKSPACE is not a trestle workspace (missing .trestle). Run bootstrap-trestle-workspace.sh first." >&2; exit 2; }

case "$BASELINE" in
  low) FEDRAMP_LEVEL="LOW" ;;
  moderate) FEDRAMP_LEVEL="MODERATE" ;;
  high) FEDRAMP_LEVEL="HIGH" ;;
  li-saas) FEDRAMP_LEVEL="LI-SaaS" ;;
  *) echo "[$SOURCE] unsupported baseline '$BASELINE'. Use: low, moderate, high, li-saas" >&2; exit 2 ;;
esac

PROFILE_ALIAS="fedramp-rev5-$BASELINE"
FEDRAMP_URL="$FEDRAMP_BASE_URL/FedRAMP_rev5_${FEDRAMP_LEVEL}-baseline_profile.json"

command -v trestle >/dev/null 2>&1 || {
  echo "[$SOURCE] Compliance Trestle CLI not found. Install with: pip install compliance-trestle" >&2
  exit 5
}
command -v curl >/dev/null 2>&1 || { echo "[$SOURCE] curl not found" >&2; exit 5; }

mkdir -p "$CACHE_DIR"
CATALOG_FILE="$CACHE_DIR/NIST_SP-800-53_rev5_catalog.json"
PROFILE_FILE="$CACHE_DIR/FedRAMP_rev5_${FEDRAMP_LEVEL}-baseline_profile.json"
PROFILE_LOCAL="$CACHE_DIR/FedRAMP_rev5_${FEDRAMP_LEVEL}-baseline_profile.trestle-href.json"

download() {
  local url="$1" dest="$2" label="$3"
  if [[ -s "$dest" ]]; then
    echo "[$SOURCE] using cached $label: $dest"
    return 0
  fi
  echo "[$SOURCE] downloading $label ..."
  if ! curl -fsSL --retry 3 --retry-delay 2 --max-time 300 -o "$dest.tmp" "$url"; then
    rm -f "$dest.tmp"
    cat >&2 <<EOF
[$SOURCE] failed to download $label from:
  $url
If this environment restricts network egress, allow raw.githubusercontent.com
or pre-populate the cache directory: $CACHE_DIR
EOF
    return 1
  fi
  mv "$dest.tmp" "$dest"
}

download "$NIST_CATALOG_URL" "$CATALOG_FILE" "NIST 800-53 Rev 5 catalog" || exit 5
download "$FEDRAMP_URL" "$PROFILE_FILE" "FedRAMP Rev 5 $FEDRAMP_LEVEL baseline profile" || exit 5

python3 - "$CATALOG_FILE" "$PROFILE_FILE" "$PROFILE_LOCAL" "$CATALOG_ALIAS" <<'PY'
import json, sys
catalog_file, profile_file, profile_local, catalog_alias = sys.argv[1:]
catalog = json.load(open(catalog_file, encoding="utf-8"))
if "catalog" not in catalog:
    raise SystemExit(f"downloaded catalog is not an OSCAL catalog: {catalog_file}")
profile = json.load(open(profile_file, encoding="utf-8"))
if "profile" not in profile:
    raise SystemExit(f"downloaded profile is not an OSCAL profile: {profile_file}")
for imp in profile["profile"].get("imports", []):
    imp["href"] = f"trestle://catalogs/{catalog_alias}/catalog.json"
json.dump(profile, open(profile_local, "w", encoding="utf-8"), indent=2)
meta = catalog["catalog"]["metadata"]
print(f"[fetch-oscal-baseline] catalog: {meta.get('title','')[:80]}")
print(f"[fetch-oscal-baseline] catalog oscal-version: {meta.get('oscal-version')}")
print(f"[fetch-oscal-baseline] profile: {profile['profile']['metadata'].get('title','')[:80]}")
PY

cd "$WORKSPACE"

if [[ $OVERWRITE -eq 1 ]]; then
  rm -rf "catalogs/$CATALOG_ALIAS" "profiles/$PROFILE_ALIAS"
fi

if [[ -d "catalogs/$CATALOG_ALIAS" ]]; then
  echo "[$SOURCE] catalogs/$CATALOG_ALIAS already exists; skipping import (use --overwrite to replace)"
else
  trestle import -f "$CATALOG_FILE" -o "$CATALOG_ALIAS" >/dev/null || { echo "[$SOURCE] trestle import of catalog failed" >&2; exit 3; }
fi

if [[ -d "profiles/$PROFILE_ALIAS" ]]; then
  echo "[$SOURCE] profiles/$PROFILE_ALIAS already exists; skipping import (use --overwrite to replace)"
else
  trestle import -f "$PROFILE_LOCAL" -o "$PROFILE_ALIAS" >/dev/null || { echo "[$SOURCE] trestle import of profile failed" >&2; exit 3; }
fi

if [[ $SKIP_VALIDATE -ne 1 ]]; then
  trestle validate -t profile -n "$PROFILE_ALIAS" >/dev/null || { echo "[$SOURCE] profile validation failed" >&2; exit 3; }
fi

echo "[$SOURCE] baseline ready"
printf '  catalog: catalogs/%s\n' "$CATALOG_ALIAS"
printf '  profile: profiles/%s\n' "$PROFILE_ALIAS"
printf '  cache:   %s\n' "$CACHE_DIR"
