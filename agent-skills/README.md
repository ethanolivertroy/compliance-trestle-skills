# Compliance Trestle Agent Skills

This directory contains portable skills for coding agents. They are designed to work across Claude Code, Codex, Gemini CLI, OpenCode, Cursor, Windsurf, and generic desktop agents.

## Available skills

- `oscal-document-engineering` — convert, validate, and maintain OSCAL documents from legacy SSP/PDF/DOCX/Markdown source material.

## How to use

1. Open the skill directory relevant to your task.
2. Read `SKILL.md` completely.
3. Read any linked files under `references/`.
4. Copy templates from `templates/` into your workspace as needed.
5. Run validation commands before reporting success.

## Rules

- Preserve source traceability.
- Mark uncertainty as `needs_review`.
- Do not copy licensed framework text.
- Do not commit sensitive customer evidence.
- Prefer repeatable scripts and structured reports.

## Validate

```bash
npm run test:agent-skills
```
