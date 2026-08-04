---
name: Extract Legacy Document
description: Extract text from PDF, DOCX, Markdown, or text into normalized Markdown plus source-map and manifest files.
---

# /oscal-document-workbench:extract-legacy-doc

Extract text from PDF, DOCX, Markdown, or text into normalized Markdown plus source-map and manifest files.

## How to run

```bash
bash plugins/document-transform/oscal-document-workbench/scripts/extract-legacy-doc.sh <input> --output <dir>
```

## Arguments

- `<input>` : PDF, DOCX, Markdown, or text file
- `--output <dir>` : directory for `extracted.md`, `source-map.csv`, `sections.json`, metadata, and manifest

## Outputs

- `extracted.md`
- `source-map.csv`
- `sections.json`
- `extracted-metadata.json`
- `extract-manifest.json`

## Exit codes

- `0` : success
- `2` : bad arguments or unreadable input
- `5` : required extractor dependency is missing
- `6` : unsupported format

## Safety notes

- Keep source files unchanged.
- Maintain source traceability for every mapped OSCAL field.
- Mark uncertain mappings as `needs_review`.
- Do not treat structural validation as an audit opinion.
- Do not commit sensitive customer evidence or real SSPs.
