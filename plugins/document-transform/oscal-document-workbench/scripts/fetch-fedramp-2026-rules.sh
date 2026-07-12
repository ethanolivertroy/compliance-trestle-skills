#!/usr/bin/env bash
# Fetch the FedRAMP Consolidated Rules for 2026 (machine-readable KSI/FRR/FRD/CTL data).
set -euo pipefail

SOURCE="oscal-document-workbench:fetch-fedramp-2026-rules"
RULES_URL="${FEDRAMP_2026_RULES_URL:-https://raw.githubusercontent.com/FedRAMP/rules/main/fedramp-consolidated-rules.json}"
CACHE_DIR="${OSCAL_BASELINE_CACHE:-$HOME/.cache/oscal-baselines}"
OUTPUT=""
REFRESH=0

usage() {
  cat <<'EOF'
Usage: fetch-fedramp-2026-rules.sh [--output <path>] [--cache-dir <dir>] [--refresh]

Downloads fedramp-consolidated-rules.json from the FedRAMP/rules GitHub repository
(the machine-readable source behind FedRAMP/2026-markdown and the 2026 Consolidated
Rules site). Contains FRD definitions, FRR requirements, KSI Key Security Indicators,
and CTL control-specific requirements.

Options:
  --output <path>   Copy the rules JSON to this path (default: cache only).
  --cache-dir <dir> Cache directory (default ~/.cache/oscal-baselines, or OSCAL_BASELINE_CACHE).
  --refresh         Re-download even if a cached copy exists.

Override the source with FEDRAMP_2026_RULES_URL for mirrors or air-gapped use.
Exit codes: 0 success, 2 bad arguments, 5 download failure or missing dependency.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) shift; OUTPUT="${1:-}" ;;
    --output=*) OUTPUT="${1#*=}" ;;
    --cache-dir) shift; CACHE_DIR="${1:-}" ;;
    --cache-dir=*) CACHE_DIR="${1#*=}" ;;
    --refresh) REFRESH=1 ;;
    --help|-h) usage; exit 0 ;;
    --*) echo "[$SOURCE] unknown flag: $1" >&2; exit 2 ;;
    *) echo "[$SOURCE] unexpected argument: $1" >&2; exit 2 ;;
  esac
  shift || true
done

command -v curl >/dev/null 2>&1 || { echo "[$SOURCE] curl not found" >&2; exit 5; }

mkdir -p "$CACHE_DIR"
RULES_FILE="$CACHE_DIR/fedramp-consolidated-rules.json"

if [[ $REFRESH -eq 1 ]]; then
  rm -f "$RULES_FILE"
fi

if [[ -s "$RULES_FILE" ]]; then
  echo "[$SOURCE] using cached rules: $RULES_FILE"
else
  echo "[$SOURCE] downloading FedRAMP Consolidated Rules for 2026 ..."
  if ! curl -fsSL --retry 3 --retry-delay 2 --max-time 120 -o "$RULES_FILE.tmp" "$RULES_URL"; then
    rm -f "$RULES_FILE.tmp"
    cat >&2 <<EOF
[$SOURCE] failed to download rules from:
  $RULES_URL
If this environment restricts network egress, allow raw.githubusercontent.com
or pre-populate the cache directory: $CACHE_DIR
EOF
    exit 5
  fi
  mv "$RULES_FILE.tmp" "$RULES_FILE"
fi

python3 - "$RULES_FILE" <<'PY'
import json, sys
data = json.load(open(sys.argv[1], encoding="utf-8"))
for key in ("info", "KSI", "FRR"):
    if key not in data:
        raise SystemExit(f"rules file missing expected section: {key}")
info = data["info"]
ksi_count = sum(len(family.get("indicators", {})) for family in data["KSI"].values())
print(f"[fetch-fedramp-2026-rules] {info.get('title', 'FedRAMP rules')}")
print(f"[fetch-fedramp-2026-rules] version: {info.get('version')} updated: {info.get('last_updated')}")
print(f"[fetch-fedramp-2026-rules] KSI families: {len(data['KSI'])} indicators: {ksi_count}")
PY

if [[ -n "$OUTPUT" ]]; then
  mkdir -p "$(dirname "$OUTPUT")"
  cp "$RULES_FILE" "$OUTPUT"
  echo "[$SOURCE] copied to $OUTPUT"
fi

echo "[$SOURCE] rules ready: $RULES_FILE"
