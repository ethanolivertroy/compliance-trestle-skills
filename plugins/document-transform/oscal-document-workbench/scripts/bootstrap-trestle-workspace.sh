#!/usr/bin/env bash
# Initialize a Compliance Trestle workspace scaffold.
set -euo pipefail

SOURCE="oscal-document-workbench:bootstrap-trestle-workspace"
WORKSPACE=""
PROFILE=""
OSCAL_VERSION="1.1.3"
OSCAL_VERSION_SET=0
OVERWRITE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) shift; PROFILE="${1:-}" ;;
    --profile=*) PROFILE="${1#*=}" ;;
    --oscal-version) shift; OSCAL_VERSION="${1:-}"; OSCAL_VERSION_SET=1 ;;
    --oscal-version=*) OSCAL_VERSION="${1#*=}"; OSCAL_VERSION_SET=1 ;;
    --overwrite) OVERWRITE=1 ;;
    --help|-h) echo "Usage: $0 <workspace> [--profile <name>] [--oscal-version <version>] [--overwrite]"; exit 0 ;;
    --*) echo "[$SOURCE] unknown flag: $1" >&2; exit 2 ;;
    *) if [[ -z "$WORKSPACE" ]]; then WORKSPACE="$1"; else echo "[$SOURCE] unexpected argument: $1" >&2; exit 2; fi ;;
  esac
  shift || true
done

[[ -n "$WORKSPACE" ]] || { echo "Usage: $0 <workspace> [--profile <name>] [--oscal-version <version>] [--overwrite]" >&2; exit 2; }

TRESTLE_DIR="$WORKSPACE/trestle-workspace"
REPORT_DIR="$WORKSPACE/reports"
if [[ -e "$TRESTLE_DIR" && $OVERWRITE -ne 1 ]]; then
  echo "[$SOURCE] $TRESTLE_DIR already exists. Pass --overwrite to replace generated scaffold." >&2
  exit 2
fi

mkdir -p "$WORKSPACE" "$REPORT_DIR"
if [[ -e "$TRESTLE_DIR" && $OVERWRITE -eq 1 ]]; then
  rm -rf "$TRESTLE_DIR"
fi
mkdir -p "$TRESTLE_DIR"

if command -v trestle >/dev/null 2>&1; then
  init_err="$(mktemp)"
  if ! (cd "$TRESTLE_DIR" && trestle init >"$init_err" 2>&1); then
    cat "$init_err" >&2
    rm -f "$init_err"
    echo "[$SOURCE] trestle init failed" >&2
    exit 3
  fi
  rm -f "$init_err"
  detected_version="$(trestle version 2>/dev/null | sed -n 's/.*OSCAL version //p' | awk '{print $1}')"
  if [[ "$OSCAL_VERSION_SET" -eq 0 && -n "$detected_version" ]]; then
    OSCAL_VERSION="$detected_version"
  fi
  TRESTLE_STATUS="initialized-with-trestle"
else
  mkdir -p "$TRESTLE_DIR/system-security-plans" "$TRESTLE_DIR/catalogs" "$TRESTLE_DIR/profiles" "$TRESTLE_DIR/component-definitions"
  TRESTLE_STATUS="scaffolded-without-trestle"
fi

cat > "$TRESTLE_DIR/README.md" <<EOF
# Compliance Trestle Workspace

Status: $TRESTLE_STATUS
Profile: ${PROFILE:-not specified}
OSCAL version target: $OSCAL_VERSION

Use this workspace to author and validate OSCAL.
If this workspace was scaffolded without Trestle, install Compliance Trestle.
Run \`trestle init\` here before full authoring.

Guardrails:
- Keep source traceability.
- Mark uncertain mappings as \`needs_review\`.
- Validate before delivery.
EOF

cat > "$REPORT_DIR/import-summary.md" <<EOF
# Import Summary

- Workspace: $WORKSPACE
- Trestle workspace: $TRESTLE_DIR
- Status: $TRESTLE_STATUS
- Profile: ${PROFILE:-not specified}
- OSCAL version: $OSCAL_VERSION

## Next steps

1. Review the extracted source material.
2. Make the source traceability map.
3. Map content to the OSCAL SSP structure.
4. Run validation.
5. Resolve \`needs_review\` items.
EOF

cat > "$REPORT_DIR/unmapped-items.md" <<EOF
# Unmapped Items

Record source sections that have no OSCAL mapping.

| Source ID | Reason | Recommendation | Status |
|---|---|---|---|
EOF

echo "[$SOURCE] $TRESTLE_STATUS"
printf '  workspace: %s\n' "$WORKSPACE"
printf '  trestle:   %s\n' "$TRESTLE_DIR"
printf '  reports:   %s\n' "$REPORT_DIR"
