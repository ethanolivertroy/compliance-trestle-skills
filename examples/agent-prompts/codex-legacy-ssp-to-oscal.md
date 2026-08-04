# Codex Prompt: Legacy SSP to OSCAL

Read `AGENTS.md`. Then do this task.

Use this repository's portable OSCAL document engineering workflow.

Task: Convert `<source-file>` into a traceable OSCAL SSP workspace.

Requirements:

- Read `agent-skills/oscal-document-engineering/SKILL.md` first.
- Keep the original source file unchanged.
- Make a source traceability map for every mapped OSCAL field.
- Use Compliance Trestle when available.
- Validate with Trestle and OSCAL CLI when available.
- Mark uncertain mappings as `needs_review`.
- Make `import-summary.md`, `validation-report.json`, and `unmapped-items.md`.
- Do not treat structural validation as an audit opinion.
