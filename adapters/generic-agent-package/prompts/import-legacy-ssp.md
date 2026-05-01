# Prompt: import a legacy SSP

Use `AGENTS.md`, `agent-skills/oscal-document-engineering/SKILL.md`, and `agent-skills/compliance-trestle-engineering/SKILL.md`.

Task: import the provided legacy SSP package into an OSCAL Document Workbench workspace.

Requirements:

- Extract source text.
- Generate `source-map.csv`, `sections.json`, and `extract-manifest.json`.
- Bootstrap a Compliance Trestle workspace.
- Draft OSCAL SSP content only where source text supports it.
- Mark uncertain mappings as `needs_review`.
- Generate a review queue.
- Run validation or document missing tools.
- Do not claim schema-valid OSCAL proves compliance effectiveness.
