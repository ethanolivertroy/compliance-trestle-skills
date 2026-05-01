#!/usr/bin/env bash
# Build a human review queue from a source-map.csv.
set -euo pipefail
SOURCE_MAP="${1:-}"
OUTPUT="${2:-}"
[[ -n "$SOURCE_MAP" && -n "$OUTPUT" ]] || { echo "Usage: $0 <source-map.csv> <review-queue.md>" >&2; exit 2; }
[[ -r "$SOURCE_MAP" ]] || { echo "cannot read source map: $SOURCE_MAP" >&2; exit 2; }
mkdir -p "$(dirname "$OUTPUT")"
python3 - "$SOURCE_MAP" "$OUTPUT" <<'PY'
import csv, sys
source, out = sys.argv[1], sys.argv[2]
rows=list(csv.DictReader(open(source, newline='', encoding='utf-8')))
review=[r for r in rows if (r.get('status','').strip().lower() in {'needs_review','pending','unmapped',''} or not r.get('oscal_target','').strip())]
with open(out,'w',encoding='utf-8') as f:
    f.write('# OSCAL import review queue\n\n')
    f.write('Schema-valid OSCAL does not prove compliance effectiveness. Review every uncertain mapping before relying on generated content.\n\n')
    f.write(f'- Source rows: {len(rows)}\n')
    f.write(f'- Review items: {len(review)}\n\n')
    f.write('| Source ID | Heading | OSCAL target | Status | Reviewer decision | Notes |\n')
    f.write('| --- | --- | --- | --- | --- | --- |\n')
    for r in review:
        f.write('| {source_id} | {heading} | {oscal_target} | {status} |  | {notes} |\n'.format(**{k:(v or '').replace('|','/') for k,v in r.items()}))
print(f'Wrote {out} with {len(review)} review item(s).')
if review:
    sys.exit(1)
PY
