#!/usr/bin/env bash
# Consistent Compliance Trestle workspace wrapper for agent workflows.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/trestle-workflow.sh <init|status|validate|assemble|command-log> <workspace> [args]

Commands:
  init <workspace>                         Initialize a Trestle workspace or scaffold if trestle is missing.
  status <workspace>                       Print workspace/tool status.
  validate <workspace>                     Run trestle validate -a or write skipped report.
  assemble <workspace> <markdown-path>     Run trestle author ssp-assemble when available.
  command-log <workspace>                  Create reports/trestle-command-log.md if missing.
EOF
}

cmd="${1:-}"; workspace="${2:-}"
[[ -n "$cmd" && -n "$workspace" ]] || { usage >&2; exit 2; }
shift 2 || true
mkdir -p "$workspace/reports"
report="$workspace/reports/trestle-wrapper-report.md"
log="$workspace/reports/trestle-command-log.md"

ts() { date -u +%Y-%m-%dT%H:%M:%SZ; }
append_log() {
  [[ -f "$log" ]] || cat > "$log" <<'EOF'
# Trestle command log

| Timestamp | Workspace | Command | Exit code | Output artifact | Notes |
| --- | --- | --- | ---: | --- | --- |
EOF
  printf '| %s | %s | `%s` | %s | %s | %s |\n' "$(ts)" "$workspace" "$1" "$2" "$3" "$4" >> "$log"
}

has_trestle=false
if command -v trestle >/dev/null 2>&1; then has_trestle=true; fi

case "$cmd" in
  init)
    mkdir -p "$workspace"
    if $has_trestle; then
      (cd "$workspace" && trestle init)
      code=$?; append_log 'trestle init' "$code" "$workspace" 'initialized with trestle'; exit "$code"
    fi
    mkdir -p "$workspace"/{catalogs,profiles,component-definitions,system-security-plans,markdown,reports}
    cat > "$report" <<EOF
# Trestle wrapper report

Status: skipped
Reason: Compliance Trestle CLI was not found.
Generated scaffold only. Install trestle before treating validation or assembly as complete.
EOF
    append_log 'trestle init' 127 "$report" 'trestle missing; scaffold created'
    ;;
  status)
    {
      echo '# Trestle workspace status'
      echo
      echo "Workspace: $workspace"
      echo "Generated: $(ts)"
      if $has_trestle; then trestle version || true; else echo 'Compliance Trestle: missing'; fi
      echo
      echo 'Important directories:'
      for d in catalogs profiles component-definitions system-security-plans markdown reports; do
        [[ -d "$workspace/$d" ]] && echo "- present: $d" || echo "- missing: $d"
      done
    } > "$report"
    append_log 'trestle status' 0 "$report" 'status captured'
    cat "$report"
    ;;
  validate)
    if $has_trestle; then
      set +e
      (cd "$workspace" && trestle validate -a) > "$workspace/reports/trestle-validate.log" 2>&1
      code=$?
      set -e
      append_log 'trestle validate -a' "$code" "$workspace/reports/trestle-validate.log" 'validation run'
      exit "$code"
    fi
    cat > "$workspace/reports/trestle-validate.log" <<EOF
Status: skipped
Reason: Compliance Trestle CLI was not found.
EOF
    append_log 'trestle validate -a' 127 "$workspace/reports/trestle-validate.log" 'trestle missing; validation skipped'
    ;;
  assemble)
    markdown_path="${1:-}"
    [[ -n "$markdown_path" ]] || { echo 'assemble requires markdown path' >&2; exit 2; }
    if $has_trestle; then
      set +e
      (cd "$workspace" && trestle author ssp-assemble -m "$markdown_path") > "$workspace/reports/trestle-assemble.log" 2>&1
      code=$?
      set -e
      append_log "trestle author ssp-assemble -m $markdown_path" "$code" "$workspace/reports/trestle-assemble.log" 'assembly run'
      exit "$code"
    fi
    cat > "$workspace/reports/trestle-assemble.log" <<EOF
Status: skipped
Reason: Compliance Trestle CLI was not found.
Requested markdown path: $markdown_path
EOF
    append_log "trestle author ssp-assemble -m $markdown_path" 127 "$workspace/reports/trestle-assemble.log" 'trestle missing; assembly skipped'
    ;;
  command-log)
    append_log 'trestle command-log' 0 "$log" 'command log ensured'
    ;;
  *) usage >&2; exit 2 ;;
esac
