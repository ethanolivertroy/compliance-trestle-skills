#!/bin/bash
set -euo pipefail

# PreToolUse hook: warn when directly editing OSCAL JSON/YAML files
# in model directories (should use trestle authoring workflow instead).
# Exit 0 always so the edit is not blocked. Exit 2 would deny the tool call.

parse_file_path() {
  local input="$1"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.filePath // empty'
    return 0
  fi
  python3 - "$input" <<'PY' 2>/dev/null || true
import json, sys
try:
    data = json.loads(sys.argv[1])
except Exception:
    raise SystemExit(0)
tool = data.get("tool_input") or {}
print(tool.get("file_path") or tool.get("filePath") or "")
PY
}

input="$(cat)"
file_path="$(parse_file_path "$input")"

if [[ -z "$file_path" ]]; then
  exit 0
fi

if [[ ! "$file_path" =~ \.(json|yaml|yml)$ ]]; then
  exit 0
fi

# Walk from the edited file toward root to find a trestle workspace.
search_path="$file_path"
if [[ -f "$search_path" || "$search_path" == *.* ]]; then
  search_path="$(dirname "$search_path")"
fi
trestle_root=""
while [[ -n "$search_path" && "$search_path" != "/" ]]; do
  if [[ -d "$search_path/.trestle" ]]; then
    trestle_root="$search_path"
    break
  fi
  search_path="$(dirname "$search_path")"
done

if [[ -z "$trestle_root" && ! -d ".trestle" ]]; then
  exit 0
fi

author_pattern='/(catalogs|profiles|component-definitions|system-security-plans)/'
json_pattern='/(assessment-plans|assessment-results|plan-of-action-and-milestones)/'

if [[ "$file_path" =~ $author_pattern ]]; then
  cat >&2 <<'EOF'
{"systemMessage": "Warning: You are directly editing an OSCAL model file. Direct JSON/YAML edits bypass trestle's authoring workflow and may cause validation issues. Prefer trestle author generate/assemble. If this edit is intentional, continue and validate afterward with: trestle validate -a"}
EOF
  exit 0
fi

if [[ "$file_path" =~ $json_pattern ]]; then
  cat >&2 <<'EOF'
{"systemMessage": "Note: You are editing an OSCAL model that uses the JSON-based workflow (no trestle author commands available for this model type). This is the correct approach. Use trestle split/merge to manage sections and validate afterward with: trestle validate -a"}
EOF
  exit 0
fi

exit 0
