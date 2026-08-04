#!/bin/bash
set -euo pipefail

# Session start hook: detect trestle workspace and provide context

find_trestle_root() {
  local path
  path="$(pwd)"
  while [[ "$path" != "/" ]]; do
    if [[ -d "$path/.trestle" ]]; then
      printf '%s\n' "$path"
      return 0
    fi
    path="$(dirname "$path")"
  done
  return 1
}

trestle_root="$(find_trestle_root || true)"
if [[ -z "$trestle_root" ]]; then
  exit 0
fi

models=()
model_dirs=("catalogs" "profiles" "component-definitions" "system-security-plans" "assessment-plans" "assessment-results" "plan-of-action-and-milestones")

for dir in "${model_dirs[@]}"; do
  if [[ -d "$trestle_root/$dir" ]]; then
    count=$(find "$trestle_root/$dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$count" -gt 0 ]]; then
      models+=("$dir ($count)")
    fi
  fi
done

dist_count=0
if [[ -d "$trestle_root/dist" ]]; then
  dist_count=$(find "$trestle_root/dist" \( -name '*.json' -o -name '*.yaml' -o -name '*.yml' \) 2>/dev/null | wc -l | tr -d ' ')
fi

settings_info=""
settings_file="$trestle_root/.claude/compliance-trestle.local.md"
if [[ -f "$settings_file" ]]; then
  settings_info="Project settings loaded from $settings_file."
fi

echo "Trestle workspace detected at $trestle_root."

if [[ ${#models[@]} -gt 0 ]]; then
  model_list=$(printf '%s, ' "${models[@]}")
  echo "Models: ${model_list%, }."
fi

if [[ "$dist_count" -gt 0 ]]; then
  echo "Assembled outputs: $dist_count files in dist/."
fi

if [[ -n "$settings_info" ]]; then
  echo "$settings_info"
fi

echo "Use /compliance-trestle:workspace-status for details or /compliance-trestle:workspace-validate to check model health."
