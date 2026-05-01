#!/usr/bin/env bash
# Validate an OSCAL file or package with available validators.
set -euo pipefail

SOURCE="oscal-document-workbench:validate-oscal-package"
TARGET=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) shift; OUTPUT="${1:-}" ;;
    --output=*) OUTPUT="${1#*=}" ;;
    --help|-h) echo "Usage: $0 <oscal-file-or-package-dir> [--output <report.json>]"; exit 0 ;;
    --*) echo "[$SOURCE] unknown flag: $1" >&2; exit 2 ;;
    *) if [[ -z "$TARGET" ]]; then TARGET="$1"; else echo "[$SOURCE] unexpected argument: $1" >&2; exit 2; fi ;;
  esac
  shift || true
done

[[ -n "$TARGET" ]] || { echo "Usage: $0 <oscal-file-or-package-dir> [--output <report.json>]" >&2; exit 2; }
[[ -e "$TARGET" ]] || { echo "[$SOURCE] target does not exist: $TARGET" >&2; exit 2; }
[[ -n "$OUTPUT" ]] || OUTPUT="validation-report.json"
mkdir -p "$(dirname "$OUTPUT")"

STATUS="pass"
ERRORS_FILE="$(mktemp)"
VALIDATORS_FILE="$(mktemp)"
: > "$ERRORS_FILE"
: > "$VALIDATORS_FILE"

run_validator() {
  local name="$1"; shift
  echo "$name" >> "$VALIDATORS_FILE"
  if "$@" >>/tmp/oscal-workbench-validator.out 2>>"$ERRORS_FILE"; then
    return 0
  fi
  STATUS="fail"
  return 1
}

if command -v trestle >/dev/null 2>&1; then
  if [[ -f "$TARGET" ]]; then
    run_validator "trestle validate" trestle validate -f "$TARGET" || true
  else
    # Trestle validates files, not arbitrary dirs. Validate discovered JSON/YAML/XML OSCAL-like files.
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      run_validator "trestle validate:$file" trestle validate -f "$file" || true
    done < <(find "$TARGET" -type f \( -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.xml' \) | sort)
  fi
else
  echo "trestle:not_found" >> "$VALIDATORS_FILE"
  [[ "$STATUS" == "pass" ]] && STATUS="partial"
fi

OSCAL_VALIDATE="plugins/oscal/scripts/validate.sh"
if [[ -x "$OSCAL_VALIDATE" || -f "$OSCAL_VALIDATE" ]]; then
  if [[ -f "$TARGET" ]]; then
    bash "$OSCAL_VALIDATE" "$TARGET" --json >/tmp/oscal-validate.json 2>>"$ERRORS_FILE" || STATUS="fail"
    echo "oscal-cli wrapper" >> "$VALIDATORS_FILE"
  fi
else
  echo "oscal-wrapper:not_found" >> "$VALIDATORS_FILE"
  [[ "$STATUS" == "pass" ]] && STATUS="partial"
fi

ERROR_JSON=$(node -e 'const fs=require("fs"); const p=process.argv[1]; const lines=fs.readFileSync(p,"utf8").split(/\n/).filter(Boolean); process.stdout.write(JSON.stringify(lines));' "$ERRORS_FILE")
VALIDATORS_JSON=$(node -e 'const fs=require("fs"); const p=process.argv[1]; const lines=[...new Set(fs.readFileSync(p,"utf8").split(/\n/).filter(Boolean))]; process.stdout.write(JSON.stringify(lines));' "$VALIDATORS_FILE")
node -e '
const fs=require("fs");
const report={target:process.argv[1],status:process.argv[2],validators:JSON.parse(process.argv[3]),errors:JSON.parse(process.argv[4]),generated_at:new Date().toISOString(),note:"Structural validation only; not an audit opinion."};
fs.writeFileSync(process.argv[5], JSON.stringify(report,null,2)+"\n");
' "$TARGET" "$STATUS" "$VALIDATORS_JSON" "$ERROR_JSON" "$OUTPUT"

rm -f "$ERRORS_FILE" "$VALIDATORS_FILE"
echo "[$SOURCE] status: $STATUS"
printf '  report: %s\n' "$OUTPUT"
[[ "$STATUS" == "fail" ]] && exit 3
exit 0
