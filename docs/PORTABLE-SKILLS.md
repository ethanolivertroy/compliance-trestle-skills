# Portable Skills

Portable skills are vendor-neutral task playbooks.
Coding agents can read and execute them.
They do not require Claude Code slash commands or plugin installation.

## Directory structure

```text
agent-skills/
├── manifest.json
└── <skill-name>/
    ├── SKILL.md
    ├── references/
    ├── templates/
    ├── scripts/
    └── assets/
```

Only `SKILL.md` is required.
Supporting directories are optional.

## `SKILL.md` frontmatter

Each skill must start with YAML frontmatter:

```yaml
---
name: oscal-document-engineering
description: Convert, validate, and maintain OSCAL documents from legacy source material.
tags: [oscal, ssp, compliance-trestle, document-transformation]
---
```

Required fields:

- `name` : directory-safe skill name.
- `description` : one-sentence trigger and usage description.

Recommended fields:

- `tags` : topics and tool names.
- `related_skills` : sibling portable skills.
- `required_commands` : external CLI tools when applicable.

## Writing rules

- Write skill text in ASD-STE100 Simplified Technical English.
- Make the skill usable by any coding agent that can read files.
- Include exact commands and output artifacts.
- Include guardrails and failure modes.
- Link to references and templates with relative paths.
- Do not assume slash-command support.
- Do not include sensitive examples or licensed framework text.

## Relationship to Claude Code plugins

Claude Code plugins under `plugins/` stay supported.
Portable skills are the agent-neutral layer.
Plugin skills can point to portable skills.
Plugin skills can also copy selected content.
A future release can generate plugin skills from portable skills.

## Packaging into agent tools

- Claude Code: install the marketplace plugin, or read portable skills directly.
- Codex and OpenAI coding agents: use `AGENTS.md` and `agent-skills/`.
- Gemini CLI: use `GEMINI.md` and `agent-skills/`.
- OpenCode: use `OPENCODE.md` and `agent-skills/`.
- Cursor: use `CURSOR.md`, native project skills in `.cursor/skills/`, and the portable skill source in `agent-skills/`.
- Devin Desktop (formerly Windsurf): use `.devin/rules/` plus the portable skills. `.windsurf/rules/` is a fallback only.
- Other IDE agents: use harness rules plus the portable skills.

## Validation

Run:

```bash
npm run test:agent-skills
```

The validator checks manifest JSON, required skill files, frontmatter, and key references.
