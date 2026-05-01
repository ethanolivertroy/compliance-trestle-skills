# Portable Skills

Portable skills are vendor-neutral task playbooks that coding agents can read and execute without relying on Claude Code slash commands or plugin installation.

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

Only `SKILL.md` is required. Supporting directories are optional.

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

- `name` — directory-safe skill name.
- `description` — one-sentence trigger/usage description.

Recommended fields:

- `tags` — topics and tool names.
- `related_skills` — sibling portable skills.
- `required_commands` — external CLI tools when applicable.

## Writing rules

- Make the skill usable by any coding agent that can read files.
- Include exact commands and output artifacts.
- Include guardrails and failure modes.
- Link to references/templates using relative paths.
- Do not assume slash-command support.
- Do not include sensitive examples or licensed framework text.

## Relationship to Claude Code plugins

Claude Code plugins under `plugins/` remain supported. Portable skills are the agent-neutral layer. Plugin skills may point to portable skills, duplicate selected content, or be generated from portable skills in a future release.

## Packaging into agent tools

- Claude Code: install the marketplace plugin, or read portable skills directly.
- Codex/OpenAI coding agents: rely on `AGENTS.md` and `agent-skills/`.
- Gemini CLI: rely on `GEMINI.md` and `agent-skills/`.
- OpenCode: rely on `OPENCODE.md` and `agent-skills/`.
- IDE agents: use `.cursor/rules/`, `.windsurf/rules/`, and the portable skills.

## Validation

Run:

```bash
npm run test:agent-skills
```

The validator checks manifest JSON, required skill files, frontmatter, and key references.
