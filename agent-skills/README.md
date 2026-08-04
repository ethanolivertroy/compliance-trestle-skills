# Compliance Trestle Agent Skills

This directory contains portable skills for coding agents.
The skills work across Claude Code, Codex, Gemini CLI, OpenCode, Cursor, Devin Desktop, and generic desktop agents.

Write skill text in ASD-STE100 Simplified Technical English.

## Available skills

- `oscal-document-engineering` : convert, validate, and maintain OSCAL documents from legacy SSP, PDF, DOCX, or Markdown source material.
- `compliance-trestle-engineering` : operate Compliance Trestle workspaces for catalogs, profiles, component definitions, SSPs, assembly, and validation.

## How to use

1. Open the skill directory that matches your task.
2. Read `SKILL.md` fully.
3. Read any linked files under `references/`.
4. Copy templates from `templates/` into your workspace when you need them.
5. Run validation commands before you report success.

## Rules

- Preserve source traceability.
- Mark uncertainty as `needs_review`.
- Do not copy licensed framework text.
- Do not commit sensitive customer evidence.
- Prefer repeatable scripts and structured reports.
- Schema-valid OSCAL does not prove compliance effectiveness.

## Validate

```bash
npm run test:agent-skills
```
