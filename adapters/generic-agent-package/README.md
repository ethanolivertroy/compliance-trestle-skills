# Generic agent package

This folder supplies a simple import shape for desktop, cloud, and coding-agent apps that do not understand Claude Code plugins.

Use `manifest.agent.json` as a map to the repository instructions, portable skills, prompts, and shell tools.

## Suggested import behavior

1. Load `AGENTS.md` as the system or project instruction file.
2. Load the applicable skill from `agent-skills/`.
3. Copy one prompt from `prompts/` into the agent task.
4. Allow shell execution only inside a reviewed workspace.
5. Require source traceability and `needs_review` handling.

This package is vendor-neutral until a specific cloud or desktop plugin API is selected.
