# Agent Compatibility

This project supports multiple agent harnesses.
Claude Code is a first-class plugin marketplace target.
The project structure lets other coding agents use the same skills, docs, scripts, and schemas.

| Harness | Native install method | Reads repo instructions from | Skills/plugins | Slash commands | Best old SSP-to-OSCAL workflow | Limitations |
|---|---|---|---|---|---|---|
| Claude Code | `/plugin marketplace add oscal-compass-lab/compliance-trestle-skills` | Plugin commands, skills, `AGENTS.md` | Native Claude plugins plus portable skills | Yes | Use the bundled OSCAL Document Workbench commands, docs, and scripts. | Claude-specific marketplace format |
| Claude Work/Cowork | Local files and project context | `AGENTS.md`, `agent-skills/`, `docs/` | File-oriented skills and docs | Usually no | Read the portable OSCAL skill. Operate on workspace files. Validate with the shell. | Depends on the file access model |
| OpenAI Codex CLI | Clone or open the repository | `AGENTS.md` | Portable skills | No | Use `agent-skills/oscal-document-engineering` and direct scripts. | No Claude plugin install |
| Codex app | Attach or open the repository | `AGENTS.md` | Portable skills as files | No | Same as Codex CLI. Keep outputs in the workspace. | App file permissions can change |
| Gemini CLI | Clone or open the repository | `GEMINI.md`, `AGENTS.md` | Portable skills | No | Use Gemini instructions plus the portable OSCAL skill. | No native Claude plugin commands |
| OpenCode | Open the local repository | `OPENCODE.md`, `AGENTS.md` | Portable skills | No | Map command markdown to direct shell scripts. | You must translate slash commands manually. |
| Cursor | Open the repository in the IDE | `CURSOR.md`, `.cursor/rules/`, `.cursor/skills/`, `AGENTS.md` | Native project skills plus portable skill source in `agent-skills/` | Yes (`/skill-name` in Agent chat) | Use `/import-legacy-ssp`, `/validate-oscal-package`, and other project skills. Run validations in the terminal. | Claude marketplace hooks are not available. Use rules and skills. |
| Devin Desktop (formerly Windsurf) | Open the repository in the IDE | `.devin/rules/compliance-trestle.md`, `AGENTS.md`. Fallback: `.windsurf/rules/` | Portable skills as project files | No | Use IDE rules and the portable skill. Run validations in the terminal. | Windsurf is not a separate product after 2026-06-02. `.windsurf/rules/` is a fallback only. |
| Generic desktop agent app | Add the repository as a project or folder | `AGENTS.md`, `agent-skills/` | Portable skills as files | No | Read the skill. Transform docs in the workspace. Validate with the shell. | Tool and file access can change. |
| CI/headless shell | Git checkout | scripts and tests | None | No | Run scripts directly for extraction, review-queue generation, and validation. | No LLM reasoning unless you pair the scripts with an agent. |

## Compatibility principles

- Root `commands/`, `skills/`, and `agents/` are canonical for Claude Trestle domain behavior.
- `plugins/document-transform/` is canonical for the OSCAL document workbench add-on.
- `agent-skills/` is canonical for portable agent playbooks shared across harnesses.
- `.cursor/skills/` contains thin Cursor wrappers plus symlinks into `agent-skills/`.
- Root instruction files adapt the same workflows to different harnesses.
- Direct scripts must stay runnable without a specific LLM vendor.

## Choosing a path

- Use the Claude Code marketplace if you want native slash commands.
- Use portable skills if your agent can read local files but does not support Claude plugins.
- Use direct scripts in CI or when you need deterministic validation.
