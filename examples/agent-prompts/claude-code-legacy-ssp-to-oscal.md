# Claude Code Prompt: Legacy SSP to OSCAL

Install/use the OSCAL Document Workbench plugin if available, then run the workflow below.

Use this repository's portable OSCAL document engineering workflow.

Task: Convert `<source-file>` into a traceable OSCAL SSP workspace.

Requirements:
- Read `agent-skills/oscal-document-engineering/SKILL.md` first.
- Preserve the original source file unchanged.
- Create a source traceability map for every mapped OSCAL field.
- Use Compliance Trestle when available.
- Validate with Trestle and OSCAL CLI when available.
- Mark uncertain mappings as `needs_review`.
- Produce `import-summary.md`, `validation-report.json`, and `unmapped-items.md`.
- Do not treat structural validation as an audit opinion.

If slash commands are available, prefer `/oscal-document-workbench:ingest-ssp`. Otherwise run the scripts directly.
