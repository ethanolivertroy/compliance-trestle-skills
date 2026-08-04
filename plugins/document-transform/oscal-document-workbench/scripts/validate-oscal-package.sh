#!/usr/bin/env bash
# Validate an OSCAL file or package with available validators.
set -euo pipefail

SOURCE="oscal-document-workbench:validate-oscal-package"
TARGET=""
OUTPUT=""
ALLOW_PARTIAL=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) shift; OUTPUT="${1:-}" ;;
    --output=*) OUTPUT="${1#*=}" ;;
    --allow-partial) ALLOW_PARTIAL=1 ;;
    --help|-h)
      printf 'Usage: %s <oscal-file-or-package-dir> [--output <report.json>] [--allow-partial]\n' "$0"
      exit 0
      ;;
    --*) printf '[%s] unknown flag: %s\n' "$SOURCE" "$1" >&2; exit 2 ;;
    *) if [[ -z "$TARGET" ]]; then TARGET="$1"; else printf '[%s] unexpected argument: %s\n' "$SOURCE" "$1" >&2; exit 2; fi ;;
  esac
  shift || true
done

[[ -n "$TARGET" ]] || { printf 'Usage: %s <oscal-file-or-package-dir> [--output <report.json>] [--allow-partial]\n' "$0" >&2; exit 2; }
[[ -e "$TARGET" ]] || { printf '[%s] target does not exist: %s\n' "$SOURCE" "$TARGET" >&2; exit 2; }
[[ -n "$OUTPUT" ]] || OUTPUT="validation-report.json"
mkdir -p "$(dirname "$OUTPUT")"
command -v python3 >/dev/null 2>&1 || { printf '[%s] python3 is required\n' "$SOURCE" >&2; exit 5; }

if [[ -d "$TARGET" ]]; then
  TARGET="$(cd "$TARGET" && pwd -P)"
else
  TARGET="$(cd "$(dirname "$TARGET")" && pwd -P)/$(basename "$TARGET")"
fi

STATUS="pass"
WORKDIR="$(mktemp -d)"
ERRORS_FILE="$WORKDIR/errors.txt"
VALIDATORS_FILE="$WORKDIR/validators.txt"
: > "$ERRORS_FILE"
: > "$VALIDATORS_FILE"
trap 'rm -rf "$WORKDIR"' EXIT

run_validator() {
  local name="$1"; shift
  local log="$WORKDIR/validator.log"
  : > "$log"
  printf '%s\n' "$name" >> "$VALIDATORS_FILE"
  if "$@" >"$log" 2>&1; then
    return 0
  fi
  STATUS="fail"
  { printf '[%s]\n' "$name"; cat "$log"; printf '\n'; } >> "$ERRORS_FILE"
  return 1
}

find_trestle_root() {
  local path="$1"
  if [[ -f "$path" ]]; then
    path="$(dirname "$path")"
  fi
  path="$(cd "$path" && pwd -P)"
  while [[ "$path" != "/" ]]; do
    if [[ -d "$path/.trestle" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
    path="$(dirname "$path")"
  done
  return 1
}

oscal_root_model() {
  python3 - "$1" <<'PY'
import json, sys
models = {
    "catalog",
    "profile",
    "component-definition",
    "system-security-plan",
    "assessment-plan",
    "assessment-results",
    "plan-of-action-and-milestones",
    "mapping-collection",
}
try:
    doc = json.loads(open(sys.argv[1], encoding="utf-8").read())
except Exception:
    raise SystemExit(0)
if isinstance(doc, dict) and len(doc) == 1 and next(iter(doc)) in models:
    sys.stdout.write(next(iter(doc)))
PY
}

if command -v trestle >/dev/null 2>&1; then
  if [[ -d "$TARGET/.trestle" ]]; then
    run_validator "trestle validate -a" bash -c 'cd "$1" && shift && exec "$@"' _ "$TARGET" trestle validate -a || true
  elif [[ -f "$TARGET" ]]; then
    trestle_root="$(find_trestle_root "$TARGET" || true)"
    if [[ -n "$trestle_root" ]]; then
      rel_target="${TARGET#"$trestle_root"/}"
      run_validator "trestle validate" bash -c 'cd "$1" && shift && exec "$@"' _ "$trestle_root" trestle validate -f "$rel_target" || true
    else
      run_validator "trestle validate" trestle validate -f "$TARGET" || true
    fi
  else
    nested_root="$(find "$TARGET" -type d -name .trestle -print -quit 2>/dev/null || true)"
    if [[ -n "$nested_root" ]]; then
      trestle_root="$(dirname "$nested_root")"
      run_validator "trestle validate -a" bash -c 'cd "$1" && shift && exec "$@"' _ "$trestle_root" trestle validate -a || true
    else
      while IFS= read -r file; do
        [[ -n "$file" ]] || continue
        [[ -n "$(oscal_root_model "$file")" ]] || continue
        trestle_root="$(find_trestle_root "$file" || true)"
        if [[ -n "$trestle_root" ]]; then
          rel_target="${file#"$trestle_root"/}"
          run_validator "trestle validate:$rel_target" bash -c 'cd "$1" && shift && exec "$@"' _ "$trestle_root" trestle validate -f "$rel_target" || true
        else
          run_validator "trestle validate:$file" trestle validate -f "$file" || true
        fi
      done < <(find "$TARGET" -type f \( -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.xml' \) \
        ! -path '*/extracted/*' ! -path '*/reports/*' ! -path '*/.trestle/*' | sort)
    fi
  fi
else
  printf 'trestle:not_found\n' >> "$VALIDATORS_FILE"
  [[ "$STATUS" == "pass" ]] && STATUS="partial"
fi

if command -v oscal-cli >/dev/null 2>&1; then
  if [[ -f "$TARGET" ]]; then
    model="$(oscal_root_model "$TARGET")"
    if [[ -n "$model" ]]; then
      run_validator "oscal-cli validate:$TARGET" oscal-cli validate --disable-constraint-validation --quiet --no-color "$TARGET" || true
    fi
  else
    search_root="$TARGET"
    if [[ -d "$TARGET/trestle-workspace" ]]; then
      search_root="$TARGET/trestle-workspace"
    elif [[ -d "$TARGET/.trestle" ]]; then
      search_root="$TARGET"
    fi
    while IFS= read -r file; do
      [[ -n "$file" ]] || continue
      [[ -n "$(oscal_root_model "$file")" ]] || continue
      run_validator "oscal-cli validate:$file" oscal-cli validate --disable-constraint-validation --quiet --no-color "$file" || true
    done < <(find "$search_root" -type f -name '*.json' -not -path '*/.trestle/*' -not -path '*/extracted/*' -not -path '*/reports/*' | sort)
  fi
else
  printf 'oscal-cli:not_found\n' >> "$VALIDATORS_FILE"
  [[ "$STATUS" == "pass" ]] && STATUS="partial"
fi

python3 - "$TARGET" "$STATUS" "$VALIDATORS_FILE" "$ERRORS_FILE" "$OUTPUT" <<'PY'
import json, sys
from datetime import datetime, timezone
from pathlib import Path

target, status, validators_path, errors_path, output = sys.argv[1:]
validators = []
seen = set()
for line in Path(validators_path).read_text(encoding="utf-8").splitlines():
    if line and line not in seen:
        validators.append(line)
        seen.add(line)
errors = [line for line in Path(errors_path).read_text(encoding="utf-8").splitlines() if line]
report = {
    "target": target,
    "status": status,
    "validators": validators,
    "errors": errors,
    "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "note": "Structural validation only; not an audit opinion.",
}
Path(output).write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
PY

printf '[%s] status: %s\n' "$SOURCE" "$STATUS"
printf '  report: %s\n' "$OUTPUT"
if [[ "$STATUS" == "fail" ]]; then
  exit 3
fi
if [[ "$STATUS" == "partial" && "$ALLOW_PARTIAL" -ne 1 ]]; then
  exit 5
fi
exit 0
