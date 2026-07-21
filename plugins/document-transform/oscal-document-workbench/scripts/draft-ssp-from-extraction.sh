#!/usr/bin/env bash
# Draft a schema-valid OSCAL SSP from extracted legacy sections using FedRAMP Rev 5 heading conventions.
set -euo pipefail

SOURCE="oscal-document-workbench:draft-ssp-from-extraction"
WORKSPACE=""
SSP_NAME=""
PROFILE_LABEL="fedramp-moderate"
BASELINE_PROFILE=""
TEMPLATES_DIR=""
OVERWRITE=0
SKIP_VALIDATE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ssp-name) shift; SSP_NAME="${1:-}" ;;
    --ssp-name=*) SSP_NAME="${1#*=}" ;;
    --profile-label) shift; PROFILE_LABEL="${1:-}" ;;
    --profile-label=*) PROFILE_LABEL="${1#*=}" ;;
    --baseline-profile) shift; BASELINE_PROFILE="${1:-}" ;;
    --baseline-profile=*) BASELINE_PROFILE="${1#*=}" ;;
    --templates-dir) shift; TEMPLATES_DIR="${1:-}" ;;
    --templates-dir=*) TEMPLATES_DIR="${1#*=}" ;;
    --overwrite) OVERWRITE=1 ;;
    --skip-validate) SKIP_VALIDATE=1 ;;
    --help|-h)
      cat <<'EOF'
Usage: draft-ssp-from-extraction.sh <workspace> [--ssp-name <alias>] [--profile-label <name>] [--baseline-profile <alias>] [--templates-dir <dir>] [--overwrite] [--skip-validate]

Draft a schema-valid OSCAL SSP from <workspace>/extracted/sections.json into <workspace>/trestle-workspace/.
Uses FedRAMP Rev 5 SSP heading conventions from templates/fedramp-rev5-heading-map.json.

With --baseline-profile (e.g. fedramp-rev5-moderate from fetch-oscal-baseline.sh), the SSP
imports the real baseline profile instead of generating stub catalog/profile models.
EOF
      exit 0
      ;;
    --*) echo "[$SOURCE] unknown flag: $1" >&2; exit 2 ;;
    *) if [[ -z "$WORKSPACE" ]]; then WORKSPACE="$1"; else echo "[$SOURCE] unexpected argument: $1" >&2; exit 2; fi ;;
  esac
  shift || true
done

[[ -n "$WORKSPACE" ]] || { echo "Usage: $0 <workspace> [--ssp-name <alias>] [--profile-label <name>]" >&2; exit 2; }

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
args=(python3 "$script_dir/draft-ssp-from-extraction.py" "$WORKSPACE" --profile-label "$PROFILE_LABEL")
[[ -n "$SSP_NAME" ]] && args+=(--ssp-name "$SSP_NAME")
[[ -n "$BASELINE_PROFILE" ]] && args+=(--baseline-profile "$BASELINE_PROFILE")
[[ -n "$TEMPLATES_DIR" ]] && args+=(--templates-dir "$TEMPLATES_DIR")
[[ "$OVERWRITE" -eq 1 ]] && args+=(--overwrite)
[[ "$SKIP_VALIDATE" -eq 1 ]] && args+=(--skip-validate)

"${args[@]}"
