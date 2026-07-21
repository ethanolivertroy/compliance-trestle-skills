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

find_trestle_root() {
  local path="$1"
  if [[ -f "$path" ]]; then
    path="$(dirname "$path")"
  fi
  path="$(cd "$path" && pwd)"
  while [[ "$path" != "/" ]]; do
    if [[ -d "$path/.trestle" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
    path="$(dirname "$path")"
  done
  return 1
}

if command -v trestle >/dev/null 2>&1; then
  if [[ -d "$TARGET/.trestle" ]]; then
    run_validator "trestle validate -a" bash -c "cd \"$(cd "$TARGET" && pwd)\" && trestle validate -a" || true
  elif [[ -f "$TARGET" ]]; then
    trestle_root="$(find_trestle_root "$TARGET" || true)"
    if [[ -n "$trestle_root" ]]; then
      rel_target="${TARGET#"$trestle_root"/}"
      run_validator "trestle validate" bash -c "cd \"$(cd "$trestle_root" && pwd)\" && trestle validate -f \"$rel_target\"" || true
    else
      run_validator "trestle validate" trestle validate -f "$TARGET" || true
    fi
  else
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      trestle_root="$(find_trestle_root "$file" || true)"
      if [[ -n "$trestle_root" ]]; then
        rel_target="${file#"$trestle_root"/}"
        run_validator "trestle validate:$rel_target" bash -c "cd \"$(cd "$trestle_root" && pwd)\" && trestle validate -f \"$rel_target\"" || true
      else
        run_validator "trestle validate:$file" trestle validate -f "$file" || true
      fi
    done < <(find "$TARGET" -type f \( -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.xml' \) | sort)
  fi
else
  echo "trestle:not_found" >> "$VALIDATORS_FILE"
  [[ "$STATUS" == "pass" ]] && STATUS="partial"
fi

# Schema validation with oscal-cli. Constraint validation is disabled because
# Trestle-internal trestle:// import hrefs are not resolvable outside Trestle.
oscal_root_model() {
  node -e '
const fs = require("fs");
const models = new Set(["catalog","profile","component-definition","system-security-plan","assessment-plan","assessment-results","plan-of-action-and-milestones","mapping-collection"]);
try {
  const doc = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  const keys = Object.keys(doc);
  if (keys.length === 1 && models.has(keys[0])) process.stdout.write(keys[0]);
} catch {}
' "$1"
}

validate_with_oscal_cli() {
  local file="$1"
  local model
  model="$(oscal_root_model "$file")"
  [[ -n "$model" ]] || return 0
  run_validator "oscal-cli validate:$file" oscal-cli validate --disable-constraint-validation --quiet --no-color "$file" || true
}

OSCAL_VALIDATE="plugins/oscal/scripts/validate.sh"
if command -v oscal-cli >/dev/null 2>&1; then
  if [[ -f "$TARGET" ]]; then
    validate_with_oscal_cli "$TARGET"
  else
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      validate_with_oscal_cli "$file"
    done < <(find "$TARGET" -type f -name '*.json' -not -path '*/.trestle/*' | sort)
  fi
elif [[ -x "$OSCAL_VALIDATE" || -f "$OSCAL_VALIDATE" ]]; then
  if [[ -f "$TARGET" ]]; then
    bash "$OSCAL_VALIDATE" "$TARGET" --json >/tmp/oscal-validate.json 2>>"$ERRORS_FILE" || STATUS="fail"
    echo "oscal-cli wrapper" >> "$VALIDATORS_FILE"
  fi
else
  echo "oscal-cli:not_found" >> "$VALIDATORS_FILE"
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
