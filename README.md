# Compliance Trestle Plugin for Claude Code

> **Disclaimer:** This is an independent, community-driven project and is not affiliated with, endorsed by, or officially associated with Anthropic or Claude. The author is an independent developer contributing to open source and demonstrating how these tools can be used in real-world workflows. Claude, Anthropic, and any related marks are property of their respective owners.

**v0.1.0**

Manage OSCAL compliance packages using [Compliance Trestle](https://oscal-compass.dev/compliance-trestle) — a CNCF sandbox project for machine-readable compliance documentation (NIST OSCAL standard).

## What's New in v0.1.0

**Skill depth pass** — all 10 skills now include worked examples, troubleshooting tables, and cross-references:

- **Control implementation**: Full AC-2 worked example, parameter precedence rules, multi-part and compensating controls
- **Assessment & POA&M**: Step-by-step SAP/SAR creation walkthroughs, finding-to-POA&M pipeline, milestone patterns (30/90/180-day)
- **Task system**: CSV column reference, task testing workflow, XCCDF/Tanium/CIS troubleshooting
- **Validation**: CI/CD patterns (GitHub Actions, pre-commit hooks), split-file validation, assessment/POA&M-specific issues
- **Jinja & Governance**: Assessment + POA&M report templates, security policy template example, versioned migration patterns

## Prerequisites

- Python 3.10-3.12 (Compliance Trestle does not yet support 3.13+)
- Compliance Trestle installed: `pip install compliance-trestle`
- A trestle workspace (run `trestle init` or use the `/compliance-trestle:workspace-init` command)
- Optional: [`oscal-cli`](https://github.com/metaschema-framework/oscal-cli) (requires Java 11+) for independent NIST OSCAL schema validation; `validate-oscal-package.sh` uses it automatically when it is on `PATH`

## Commands

### Workspace (7)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:workspace-init` | Initialize a new Compliance Trestle workspace |
| `/compliance-trestle:workspace-status` | Show the status of the current Trestle workspace |
| `/compliance-trestle:workspace-validate` | Validate OSCAL models in the Trestle workspace |
| `/compliance-trestle:workspace-configure` | Configure plugin settings for this project |
| `/compliance-trestle:workspace-href` | Resolve and validate href references in OSCAL models |
| `/compliance-trestle:workspace-version` | Show trestle version and OSCAL schema version info |
| `/compliance-trestle:workspace-partial-validate` | Validate a single element within a split OSCAL file |

### Author (15)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:author-catalog-generate` | Generate markdown from an OSCAL catalog for editing |
| `/compliance-trestle:author-catalog-assemble` | Assemble edited catalog markdown back into OSCAL JSON |
| `/compliance-trestle:author-profile-generate` | Generate markdown from an OSCAL profile for editing |
| `/compliance-trestle:author-profile-assemble` | Assemble edited profile markdown back into OSCAL JSON |
| `/compliance-trestle:author-profile-resolve` | Resolve a profile to produce a flattened catalog |
| `/compliance-trestle:author-profile-inherit` | Generate an inheritance view from a profile and leveraged SSP |
| `/compliance-trestle:author-component-generate` | Generate markdown from an OSCAL component definition |
| `/compliance-trestle:author-component-assemble` | Assemble edited component markdown back into OSCAL JSON |
| `/compliance-trestle:author-ssp-generate` | Generate SSP markdown from a profile and optional component definitions |
| `/compliance-trestle:author-ssp-assemble` | Assemble SSP markdown into an OSCAL System Security Plan JSON |
| `/compliance-trestle:author-ssp-filter` | Filter an SSP by profile or components |
| `/compliance-trestle:author-jinja` | Render Jinja2 templates with OSCAL data substitution |
| `/compliance-trestle:author-headers` | Manage governed YAML headers in markdown documents |
| `/compliance-trestle:author-docs` | Manage governed document structure (headings + headers) |
| `/compliance-trestle:author-folders` | Manage governed folder structure enforcement |

### Model (8)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:model-create` | Create a new OSCAL model in the workspace |
| `/compliance-trestle:model-import` | Import an existing OSCAL document into the workspace |
| `/compliance-trestle:model-split` | Split an OSCAL model into smaller sub-component files |
| `/compliance-trestle:model-merge` | Merge split OSCAL sub-components back into their parent file |
| `/compliance-trestle:model-assemble` | Assemble a split OSCAL model into a single file in dist/ |
| `/compliance-trestle:model-describe` | Describe the structure and contents of an OSCAL model |
| `/compliance-trestle:model-replicate` | Replicate (copy/rename) an OSCAL model in the workspace |
| `/compliance-trestle:model-remove` | Remove a subcomponent (element) from an OSCAL model file |

### Task (3)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:task-run` | Run a configured trestle task from config.ini |
| `/compliance-trestle:task-list` | List all configured tasks in the workspace |
| `/compliance-trestle:task-info` | Show detailed info about a specific trestle task |

### Workflow (8)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:workflow-catalog-roundtrip` | Full catalog authoring workflow — generate, edit, and assemble |
| `/compliance-trestle:workflow-profile-roundtrip` | Full profile authoring workflow — generate, edit, and assemble |
| `/compliance-trestle:workflow-component-roundtrip` | Full component definition authoring workflow |
| `/compliance-trestle:workflow-ssp-roundtrip` | Full SSP authoring workflow — generate, edit, and assemble |
| `/compliance-trestle:workflow-assessment-roundtrip` | Full assessment workflow — create, split, edit, merge, and validate assessment plans and results |
| `/compliance-trestle:workflow-poam-roundtrip` | Full POA&M workflow — create from assessment findings, track remediation, manage milestones |
| `/compliance-trestle:workflow-data-import` | Import data — OSCAL files via import, or CSV/XLSX/XCCDF via tasks |
| `/compliance-trestle:workflow-governance-setup` | Set up governance — workspace templates, config, and document-level enforcement |

## Agents (9)

| Agent | Description |
|-------|-------------|
| **compliance-reviewer** | Reviews workspace for completeness and gaps — missing implementations, validation errors, compliance posture |
| **ssp-author** | Interactive assistant for writing SSP implementation responses, control by control |
| **control-mapper** | Maps and traces controls across the full OSCAL lifecycle — catalogs, profiles, SSPs, assessments, and POA&M |
| **workspace-explorer** | Explores and explains workspace structure, model inventory, and relationships |
| **assessment-reviewer** | Reviews assessment plans and results for completeness and alignment with the SSP |
| **poam-manager** | Manages POA&M lifecycle — creates from assessment findings, tracks remediation, manages milestones |
| **validation-assistant** | Diagnoses and fixes trestle validation errors with guided troubleshooting |
| **data-importer** | Autonomous agent for importing and converting external data (CSV, XLSX, XCCDF, Tanium) into OSCAL |
| **governance-enforcer** | Autonomous agent for enforcing governance policies — template compliance, header validation, and CI/CD setup |

## Skills (10)

| Skill | Description | Key Topics |
|-------|-------------|------------|
| **trestle-workspace** | Workspace structure, initialization, and directory conventions | Init modes, config, common operations |
| **trestle-authoring-workflow** | Authoring workflows for all OSCAL model types | Generate/assemble roundtrips, JSON split/merge for assessments/POA&M |
| **trestle-oscal-models** | OSCAL model types, structure, and relationships | 7 model types, element paths, file formats |
| **trestle-control-implementation** | Writing SSP control responses | Worked AC-2 example, parameter precedence, multi-part controls, compensating controls, common mistakes |
| **trestle-assessment** | Assessment plans and results | Step-by-step SAP/SAR creation, finding-to-control traceability, XCCDF/Tanium integration |
| **trestle-poam** | POA&M lifecycle management | Creating from findings, remediation tracking, milestone examples (30/90/180-day), split/merge patterns |
| **trestle-validation** | Validation and troubleshooting | 5 validators explained, split file validation, CI/CD patterns (GitHub Actions, pre-commit), assessment/POA&M issues |
| **trestle-task-system** | Data conversion task framework | CSV column reference, task testing workflow, troubleshooting, XCCDF/Tanium/CIS tasks |
| **trestle-jinja-templating** | Jinja2 templating with OSCAL data | Custom tags/filters, SSP context, lookup tables, assessment + POA&M report templates |
| **trestle-governance** | Document governance and template enforcement | Security policy template example, global templates, versioned migration, governed folders, CI/CD |

## Hooks

The plugin includes event hooks that activate automatically:

| Hook | Event | Behavior |
|------|-------|----------|
| **Workspace Detection** | SessionStart | Detects trestle workspace, shows model inventory and available commands |
| **Validation Reminder** | PostToolUse (Bash) | After `trestle assemble`, `trestle import`, `trestle merge`, `trestle create`, or `trestle split`, provides contextual guidance |
| **OSCAL Edit Warning** | PreToolUse (Write/Edit) | Warns when directly editing OSCAL JSON/YAML files (should use authoring workflow) |

## Portable Agent Support

This repo also includes agent-portable instructions for Codex, Gemini CLI, OpenCode, Cursor, Windsurf, and generic desktop agents:

- `AGENTS.md`, `CURSOR.md`, `GEMINI.md`, `OPENCODE.md`
- `.cursor/skills/` native Cursor project skills (for example `/import-legacy-ssp`)
- `agent-skills/` portable Compliance Trestle and OSCAL document engineering skills
- `adapters/cursor/` and `adapters/generic-agent-package/` harness-specific docs and prompts
- `docs/AGENT-COMPATIBILITY.md` and `docs/PORTABLE-SKILLS.md`

## OSCAL Document Workbench

The migrated OSCAL Document Workbench lives at `plugins/document-transform/oscal-document-workbench/`. It provides command docs, scripts, templates, examples, and review workflow guidance for converting legacy SSP/PDF/DOCX/Markdown/TXT source material into source-traceable Compliance Trestle workspaces.

Start with:

- `docs/OSCAL-DOCUMENT-WORKBENCH.md`
- `docs/OSCAL-REVIEW-WORKFLOW.md`
- `docs/tutorials/legacy-ssp-to-oscal-with-agent.md`
- `examples/legacy-ssp-to-oscal/`

## Configuration

Per-project settings are stored in `.claude/compliance-trestle.local.md` (gitignored by default).

Run `/compliance-trestle:workspace-configure` to set up or modify settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `auto_validate` | `true` | Remind to validate after assembly/import |
| `default_catalog` | (empty) | Default catalog for authoring workflows |
| `default_profile` | (empty) | Default profile for SSP generation |
| `validation_level` | `normal` | `strict` treats warnings as errors |
| `ssp_format` | `markdown` | Preferred SSP editing format |

## Quick Start

```bash
# 1. Install compliance-trestle
pip install compliance-trestle

# 2. Initialize a workspace
/compliance-trestle:workspace-init

# 3. Import a catalog (e.g., NIST 800-53)
/compliance-trestle:workflow-data-import nist-800-53-rev5-catalog.json

# 4. SSP authoring workflow
/compliance-trestle:workflow-ssp-roundtrip my-ssp

# 5. Run validation
/compliance-trestle:workspace-validate

# 6. Assessment workflow
/compliance-trestle:workflow-assessment-roundtrip assessment-plan my-assessment --from-ssp my-ssp

# 7. POA&M workflow
/compliance-trestle:workflow-poam-roundtrip my-poam --from-assessment my-results --from-ssp my-ssp
```

## License

Apache-2.0
