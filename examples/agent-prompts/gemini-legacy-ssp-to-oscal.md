# Gemini CLI Prompt: Legacy SSP to OSCAL

Read `GEMINI.md` and `AGENTS.md`, then perform this task.

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
