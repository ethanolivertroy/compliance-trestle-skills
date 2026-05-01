#!/usr/bin/env bash
# Extract legacy SSP/PDF/DOCX/Markdown/TXT content into Markdown + traceability artifacts.
set -euo pipefail

SOURCE="oscal-document-workbench:extract-legacy-doc"
INPUT=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --output) shift; OUTPUT="${1:-}" ;;
    --output=*) OUTPUT="${1#*=}" ;;
    --help|-h) echo "Usage: $0 <input.{pdf|docx|md|txt}> --output <dir>"; exit 0 ;;
    --*) echo "[$SOURCE] unknown flag: $1" >&2; exit 2 ;;
    *) if [[ -z "$INPUT" ]]; then INPUT="$1"; else echo "[$SOURCE] unexpected argument: $1" >&2; exit 2; fi ;;
  esac
  shift || true
done

if [[ -z "$INPUT" || -z "$OUTPUT" ]]; then
  echo "Usage: $0 <input.{pdf|docx|md|txt}> --output <dir>" >&2
  exit 2
fi
[[ -r "$INPUT" ]] || { echo "[$SOURCE] cannot read input '$INPUT'" >&2; exit 2; }

mkdir -p "$OUTPUT"
OUT_MD="$OUTPUT/extracted.md"
SOURCE_MAP="$OUTPUT/source-map.csv"
MANIFEST="$OUTPUT/extract-manifest.json"
SECTIONS_JSON="$OUTPUT/sections.json"
METADATA_JSON="$OUTPUT/extracted-metadata.json"
BASENAME="$(basename "$INPUT")"
EXT="${BASENAME##*.}"
EXT="$(printf '%s' "$EXT" | tr '[:upper:]' '[:lower:]')"
HASH="$(sha256sum "$INPUT" | awk '{print $1}')"
EXTRACTOR=""

case "$EXT" in
  md|markdown)
    cp "$INPUT" "$OUT_MD"
    EXTRACTOR="copy-markdown"
    ;;
  txt)
    { printf '# Extracted text from %s\n\n' "$BASENAME"; cat "$INPUT"; } > "$OUT_MD"
    EXTRACTOR="copy-text"
    ;;
  docx)
    if command -v pandoc >/dev/null 2>&1; then
      pandoc "$INPUT" -t gfm -o "$OUT_MD"
      EXTRACTOR="pandoc"
    elif command -v python3 >/dev/null 2>&1 && python3 - <<'PY' >/dev/null 2>&1
import docx
PY
    then
      python3 - "$INPUT" "$OUT_MD" <<'PY'
from pathlib import Path
import sys, docx
src, out = sys.argv[1], sys.argv[2]
doc = docx.Document(src)
lines = [f"# Extracted DOCX: {Path(src).name}", ""]
for para in doc.paragraphs:
    text = para.text.strip()
    if not text:
        continue
    style = (para.style.name or '').lower() if para.style else ''
    if style.startswith('heading'):
        try: level = int(style.split()[-1])
        except Exception: level = 2
        lines.append('#' * min(max(level + 1, 2), 6) + ' ' + text)
    else:
        lines.append(text)
    lines.append('')
Path(out).write_text('\n'.join(lines), encoding='utf-8')
PY
      EXTRACTOR="python-docx"
    else
      cat >&2 <<EOF
[$SOURCE] DOCX extraction requires pandoc or python3 with python-docx.
Install one of:
  sudo apt-get install pandoc
  python3 -m pip install --user python-docx
EOF
      exit 5
    fi
    ;;
  pdf)
    if command -v pdftotext >/dev/null 2>&1; then
      pdftotext -layout "$INPUT" "$OUT_MD"
      sed -i "1i# Extracted PDF: $BASENAME\n" "$OUT_MD"
      EXTRACTOR="pdftotext"
    elif command -v python3 >/dev/null 2>&1 && python3 - <<'PY' >/dev/null 2>&1
import fitz
PY
    then
      python3 - "$INPUT" "$OUT_MD" <<'PY'
from pathlib import Path
import sys, fitz
src, out = sys.argv[1], sys.argv[2]
doc = fitz.open(src)
lines = [f"# Extracted PDF: {Path(src).name}", ""]
for i, page in enumerate(doc, start=1):
    lines.append(f"\n## Page {i}\n")
    lines.append(page.get_text())
Path(out).write_text('\n'.join(lines), encoding='utf-8')
PY
      EXTRACTOR="pymupdf"
    else
      cat >&2 <<EOF
[$SOURCE] PDF extraction requires pdftotext or python3 with PyMuPDF.
Install one of:
  sudo apt-get install poppler-utils
  python3 -m pip install --user pymupdf
EOF
      exit 5
    fi
    ;;
  *) echo "[$SOURCE] unsupported format '.$EXT'. Supported: pdf, docx, md, markdown, txt" >&2; exit 6 ;;
esac

python3 - "$OUT_MD" "$SOURCE_MAP" "$SECTIONS_JSON" "$METADATA_JSON" "$BASENAME" "$HASH" "$EXTRACTOR" <<'PY'
from pathlib import Path
import csv, hashlib, json, re, sys
md_path, source_map, sections_json, metadata_json, basename, file_hash, extractor = sys.argv[1:]
text = Path(md_path).read_text(encoding='utf-8', errors='replace')
lines = text.splitlines()
sections=[]
current={'heading':'Document root','level':1,'start_line':1,'content':[]}
for idx,line in enumerate(lines, start=1):
    m=re.match(r'^(#{1,6})\s+(.+?)\s*$', line)
    if m:
        if current['content'] or current['heading'] != 'Document root':
            body='\n'.join(current.pop('content')).strip()
            current['end_line']=idx-1
            current['text_sha256']='sha256:'+hashlib.sha256(body.encode()).hexdigest()
            current['excerpt']=body[:240]
            sections.append(current)
        current={'heading':m.group(2).strip(),'level':len(m.group(1)),'start_line':idx,'content':[]}
    else:
        current['content'].append(line)
body='\n'.join(current.pop('content')).strip()
current['end_line']=len(lines)
current['text_sha256']='sha256:'+hashlib.sha256(body.encode()).hexdigest()
current['excerpt']=body[:240]
sections.append(current)
# ensure at least one section
if not sections:
    body=text.strip()
    sections=[{'heading':'Document root','level':1,'start_line':1,'end_line':len(lines),'text_sha256':'sha256:'+hashlib.sha256(body.encode()).hexdigest(),'excerpt':body[:240]}]
for i,sec in enumerate(sections, start=1):
    sec['source_id']=f'SRC-{i:03d}'
    sec['source_file']=basename
    sec['status']='pending'
    sec['oscal_target']=''
Path(sections_json).write_text(json.dumps({'sections':sections}, indent=2)+'\n', encoding='utf-8')
metadata={'input_file':basename,'input_sha256':'sha256:'+file_hash,'extractor':extractor,'section_count':len(sections),'line_count':len(lines),'generated_outputs':['extracted.md','source-map.csv','sections.json','extracted-metadata.json','extract-manifest.json']}
Path(metadata_json).write_text(json.dumps(metadata, indent=2)+'\n', encoding='utf-8')
with open(source_map,'w',newline='',encoding='utf-8') as f:
    writer=csv.writer(f)
    writer.writerow(['source_id','source_file','page_or_section','heading','extracted_text_hash','oscal_target','status','notes'])
    for sec in sections:
        writer.writerow([sec['source_id'], basename, f"lines {sec['start_line']}-{sec['end_line']}", sec['heading'], sec['text_sha256'], '', 'pending', 'Review and map to OSCAL target'])
PY

BYTES=$(wc -c < "$OUT_MD" | tr -d ' ')
LINES=$(wc -l < "$OUT_MD" | tr -d ' ')
node -e '
const fs=require("fs");
const manifest={input:process.argv[1],input_file:process.argv[2],input_sha256:"sha256:"+process.argv[3],extractor:process.argv[4],extracted_markdown:process.argv[5],source_map:process.argv[6],sections_json:process.argv[7],metadata_json:process.argv[8],bytes:Number(process.argv[9]),lines:Number(process.argv[10]),generated_at:new Date().toISOString()};
fs.writeFileSync(process.argv[11], JSON.stringify(manifest,null,2)+"\n");
' "$INPUT" "$BASENAME" "$HASH" "$EXTRACTOR" "$OUT_MD" "$SOURCE_MAP" "$SECTIONS_JSON" "$METADATA_JSON" "$BYTES" "$LINES" "$MANIFEST"

echo "[$SOURCE] extracted with $EXTRACTOR"
printf '  markdown:   %s\n' "$OUT_MD"
printf '  source map: %s\n' "$SOURCE_MAP"
printf '  sections:   %s\n' "$SECTIONS_JSON"
printf '  metadata:   %s\n' "$METADATA_JSON"
printf '  manifest:   %s\n' "$MANIFEST"
