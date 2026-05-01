#!/usr/bin/env bash
# Initialize a Compliance Trestle workspace scaffold.
set -euo pipefail

SOURCE="oscal-document-workbench:bootstrap-trestle-workspace"
WORKSPACE=""
PROFILE=""
OSCAL_VERSION="1.1.3"
OVERWRITE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) shift; PROFILE="${1:-}" ;;
    --profile=*) PROFILE="${1#*=}" ;;
    --oscal-version) shift; OSCAL_VERSION="${1:-}" ;;
    --oscal-version=*) OSCAL_VERSION="${1#*=}" ;;
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
  (cd "$TRESTLE_DIR" && trestle init >/tmp/trestle-init.out 2>/tmp/trestle-init.err) || {
    cat /tmp/trestle-init.err >&2
    echo "[$SOURCE] trestle init failed" >&2
    exit 3
  }
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

Use this workspace to author and validate OSCAL. If this was scaffolded without Trestle, install Compliance Trestle and run \`trestle init\` here before full authoring.

Guardrails:
- Preserve source traceability.
- Mark uncertain mappings as needs_review.
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

1. Review extracted source material.
2. Populate source traceability map.
3. Map content into OSCAL SSP structure.
4. Run validation.
5. Resolve needs_review items.
EOF

cat > "$REPORT_DIR/unmapped-items.md" <<EOF
# Unmapped Items

Record source sections that could not be confidently mapped to OSCAL.

| Source ID | Reason | Recommendation | Status |
|---|---|---|---|
EOF

echo "[$SOURCE] $TRESTLE_STATUS"
printf '  workspace: %s\n' "$WORKSPACE"
printf '  trestle:   %s\n' "$TRESTLE_DIR"
printf '  reports:   %s\n' "$REPORT_DIR"
