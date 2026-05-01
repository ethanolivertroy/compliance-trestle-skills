# Legacy Document Ingestion

## Goal

Extract content from old SSP/PDF/DOCX/Markdown documents into a normalized form that can be mapped to OSCAL without losing traceability.

## Process

1. Preserve the original input file unchanged.
2. Record file name, hash, date received, and user-provided context.
3. Extract text to Markdown.
4. Preserve page numbers for PDFs and heading hierarchy for DOCX where possible.
5. Create source IDs for each section or paragraph that may map to OSCAL.
6. Fill `source-traceability-map.csv` as mappings are created.

## Dependency preferences

- DOCX: `pandoc`, then Python libraries such as `python-docx`.
- PDF: `pdftotext`, then PyMuPDF.
- Markdown/text: copy and normalize line endings.

## Quality checks

- Compare extracted heading count to original document outline where available.
- Spot-check tables, control IDs, diagrams, and footnotes.
- Treat OCR or PDF extraction errors as `needs_review`.
- Never discard source sections merely because they do not map cleanly.
