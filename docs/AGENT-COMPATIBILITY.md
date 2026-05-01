# Agent Compatibility

This project supports multiple agent harnesses. Claude Code remains a first-class plugin marketplace target, but the project is structured so other coding agents can use the same skills, docs, scripts, and schemas.

| Harness | Native install method | Reads repo instructions from | Skills/plugins | Slash commands | Best old SSP-to-OSCAL workflow | Limitations |
|---|---|---|---|---|---|---|
| Claude Code | `/plugin marketplace add oscal-compass/compliance-trestle-skills` | `CLAUDE.md`, plugin commands, skills | Native Claude plugins plus portable skills | Yes | Install `oscal`/future workbench plugin, then use command docs and scripts | Claude-specific marketplace format |
| Claude Work/Cowork | Local files/project context | `docs/CLAUDE-COWORK.md`, `AGENTS.md`, `agent-skills/` | File-oriented skills/docs | Usually no | Read portable OSCAL skill, operate on workspace files, validate with shell | Depends on file access model |
| OpenAI Codex CLI | Clone/open repository | `AGENTS.md` | Portable skills | No | Use `agent-skills/oscal-document-engineering` and direct scripts | No Claude plugin install |
| Codex app | Attach/open repository | `AGENTS.md` | Portable skills as files | No | Same as Codex CLI; keep outputs in workspace | App file permissions may vary |
| Gemini CLI | Clone/open repository | `GEMINI.md`, `AGENTS.md` | Portable skills | No | Use Gemini instructions plus portable OSCAL skill | No native Claude plugin commands |
| OpenCode | Open local repository | `OPENCODE.md`, `AGENTS.md` | Portable skills | No | Map command markdown to direct shell scripts | Must translate slash commands manually |
| Cursor | Open repository in IDE | `.cursor/rules/compliance-trestle.mdc`, `AGENTS.md` | Portable skills as project files | No | Use IDE rules and portable skill; run validations in terminal | Context loading depends on IDE settings |
| Windsurf | Open repository in IDE | `.windsurf/rules/compliance-trestle.md`, `AGENTS.md` | Portable skills as project files | No | Use IDE rules and portable skill; run validations in terminal | Context loading depends on IDE settings |
| Generic desktop agent app | Add repo as project/folder | `AGENTS.md`, `agent-skills/` | Portable skills as files | No | Read skill, transform docs in workspace, validate with shell | Tool/file access varies |
| CI/headless shell | Git checkout | scripts and tests | None | No | Run scripts directly for extraction/validation once implemented | No LLM reasoning unless paired with agent |

## Compatibility principles

- `plugins/` is canonical for existing Claude plugin behavior.
- `agent-skills/` is canonical for portable agent playbooks.
- Root instruction files adapt the same workflows to different harnesses.
- Direct scripts should remain runnable without a specific LLM vendor.

## Choosing a path

- Use Claude Code marketplace if you want native slash commands.
- Use portable skills if your agent can read local files but does not support Claude plugins.
- Use direct scripts in CI or when you need deterministic validation.
