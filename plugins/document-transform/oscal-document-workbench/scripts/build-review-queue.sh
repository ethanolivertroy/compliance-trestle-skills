#!/usr/bin/env bash
# Build a human review queue from a source-map.csv.
set -euo pipefail

SOURCE_MAP=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) shift; OUTPUT="${1:-}" ;;
    --output=*) OUTPUT="${1#*=}" ;;
    --help|-h)
      echo "Usage: $0 <source-map.csv> [--output] <review-queue.md>" >&2
      exit 0
      ;;
    --*) echo "unknown flag: $1" >&2; exit 2 ;;
    *)
      if [[ -z "$SOURCE_MAP" ]]; then SOURCE_MAP="$1"
      elif [[ -z "$OUTPUT" ]]; then OUTPUT="$1"
      else echo "unexpected argument: $1" >&2; exit 2
      fi
      ;;
  esac
  shift || true
done

[[ -n "$SOURCE_MAP" && -n "$OUTPUT" ]] || { echo "Usage: $0 <source-map.csv> [--output] <review-queue.md>" >&2; exit 2; }
[[ -r "$SOURCE_MAP" ]] || { echo "cannot read source map: $SOURCE_MAP" >&2; exit 2; }
mkdir -p "$(dirname "$OUTPUT")"
python3 - "$SOURCE_MAP" "$OUTPUT" <<'PY'
import csv, sys
source, out = sys.argv[1], sys.argv[2]

def cell(value):
    return (value or "").replace("|", "/").replace("\n", " ")

rows = list(csv.DictReader(open(source, newline="", encoding="utf-8")))
review = [
    r
    for r in rows
    if (
        r.get("status", "").strip().lower() in {"needs_review", "pending", "unmapped", ""}
        or not r.get("oscal_target", "").strip()
    )
]
with open(out, "w", encoding="utf-8") as f:
    f.write("# OSCAL import review queue\n\n")
    f.write("Schema-valid OSCAL does not prove compliance effectiveness.\n")
    f.write("Human review is required for uncertain mappings.\n\n")
    f.write(f"- Source rows: {len(rows)}\n")
    f.write(f"- Review items: {len(review)}\n\n")
    f.write("| Source ID | Heading | OSCAL target | Status | Reviewer decision | Notes |\n")
    f.write("| --- | --- | --- | --- | --- | --- |\n")
    for r in review:
        f.write(
            "| {source_id} | {heading} | {oscal_target} | {status} |  | {notes} |\n".format(
                source_id=cell(r.get("source_id")),
                heading=cell(r.get("heading")),
                oscal_target=cell(r.get("oscal_target")),
                status=cell(r.get("status")),
                notes=cell(r.get("notes")),
            )
        )
print(f"Wrote {out} with {len(review)} review item(s).")
if review:
    sys.exit(1)
PY
