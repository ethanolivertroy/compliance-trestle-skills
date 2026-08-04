# Compliance Trestle Plugin for Claude Code

> **Disclaimer:** This community lab project is hosted at [oscal-compass-lab/compliance-trestle-skills](https://github.com/oscal-compass-lab/compliance-trestle-skills). It is not the official oscal-compass CNCF project. It is not affiliated with, endorsed by, or officially associated with Anthropic, Claude, or the CNCF oscal-compass maintainers. Claude, Anthropic, Compliance Trestle, and related marks are property of their respective owners.

**v0.2.2**. See [CHANGELOG.md](CHANGELOG.md) for release history.

Use [Compliance Trestle](https://oscal-compass.dev/compliance-trestle) to manage OSCAL compliance packages.
Compliance Trestle is a CNCF sandbox project for machine-readable compliance documentation.
It uses the NIST OSCAL standard.

Project documentation uses ASD-STE100 Simplified Technical English.

## Installation

Claude Code:

```
/plugin marketplace add oscal-compass-lab/compliance-trestle-skills
```

Other agents such as Cursor, Codex, Gemini CLI, and OpenCode: see [docs/AGENT-COMPATIBILITY.md](docs/AGENT-COMPATIBILITY.md).

```bash
git clone https://github.com/oscal-compass-lab/compliance-trestle-skills.git
```

Then open the repository.
Point your agent at `AGENTS.md` and the portable skills in `agent-skills/`.

## Skill highlights

Root Trestle skills include worked examples, troubleshooting tables, and cross-references:

- **Control implementation**: AC-2 worked example, parameter precedence rules, multi-part controls, and compensating controls.
- **Assessment and POA&M**: SAP and SAR creation steps, finding-to-POA&M pipeline, and 30, 90, and 180-day milestone patterns.
- **Task system**: CSV column reference, task testing workflow, and XCCDF, Tanium, and CIS troubleshooting.
- **Validation**: CI/CD patterns for GitHub Actions and pre-commit hooks, split-file validation, and assessment or POA&M issues.
- **Jinja and Governance**: Assessment and POA&M report templates, security policy template example, and versioned migration patterns.

## Prerequisites

- Python 3.10-3.12. Compliance Trestle does not support 3.13+ yet. If you run on Python 3.14+, every trestle command prints a `UserWarning` about Pydantic V1 compatibility. The warning is expected on unsupported versions. Use 3.11 or 3.12 for a clean experience.
- Install Compliance Trestle: `pip install compliance-trestle`
- A trestle workspace. Run `trestle init` or use the `/compliance-trestle:workspace-init` command.
- Optional: [`oscal-cli`](https://github.com/metaschema-framework/oscal-cli) (Java 11 or later) for independent NIST OSCAL schema validation. `validate-oscal-package.sh` uses it when it is on `PATH`.

## Commands

### Workspace (7)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:workspace-init` | Start a new Compliance Trestle workspace. |
| `/compliance-trestle:workspace-status` | Show the status of the current Trestle workspace. |
| `/compliance-trestle:workspace-validate` | Validate OSCAL models in the Trestle workspace. |
| `/compliance-trestle:workspace-configure` | Set plugin settings for this project. |
| `/compliance-trestle:workspace-href` | Resolve and validate href references in OSCAL models. |
| `/compliance-trestle:workspace-version` | Show trestle version and OSCAL schema version information. |
| `/compliance-trestle:workspace-partial-validate` | Validate one element in a split OSCAL file. |

### Author (15)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:author-catalog-generate` | Make markdown from an OSCAL catalog for editing. |
| `/compliance-trestle:author-catalog-assemble` | Assemble edited catalog markdown into OSCAL JSON. |
| `/compliance-trestle:author-profile-generate` | Make markdown from an OSCAL profile for editing. |
| `/compliance-trestle:author-profile-assemble` | Assemble edited profile markdown into OSCAL JSON. |
| `/compliance-trestle:author-profile-resolve` | Resolve a profile to make a flat catalog. |
| `/compliance-trestle:author-profile-inherit` | Make an inheritance view from a profile and a leveraged SSP. |
| `/compliance-trestle:author-component-generate` | Make markdown from an OSCAL component definition. |
| `/compliance-trestle:author-component-assemble` | Assemble edited component markdown into OSCAL JSON. |
| `/compliance-trestle:author-ssp-generate` | Make SSP markdown from a profile and optional component definitions. |
| `/compliance-trestle:author-ssp-assemble` | Assemble SSP markdown into an OSCAL System Security Plan JSON. |
| `/compliance-trestle:author-ssp-filter` | Filter an SSP by profile or components. |
| `/compliance-trestle:author-jinja` | Render Jinja2 templates with OSCAL data substitution. |
| `/compliance-trestle:author-headers` | Manage governed YAML headers in markdown documents. |
| `/compliance-trestle:author-docs` | Manage governed document structure (headings and headers). |
| `/compliance-trestle:author-folders` | Manage governed folder structure enforcement. |

### Model (8)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:model-create` | Make a new OSCAL model in the workspace. |
| `/compliance-trestle:model-import` | Import an existing OSCAL document into the workspace. |
| `/compliance-trestle:model-split` | Split an OSCAL model into smaller sub-component files. |
| `/compliance-trestle:model-merge` | Merge split OSCAL sub-components into their parent file. |
| `/compliance-trestle:model-assemble` | Assemble a split OSCAL model into one file in dist/. |
| `/compliance-trestle:model-describe` | Describe the structure and contents of an OSCAL model. |
| `/compliance-trestle:model-replicate` | Copy or rename an OSCAL model in the workspace. |
| `/compliance-trestle:model-remove` | Remove a subcomponent from an OSCAL model file. |

### Task (3)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:task-run` | Run a configured trestle task from config.ini. |
| `/compliance-trestle:task-list` | List all configured tasks in the workspace. |
| `/compliance-trestle:task-info` | Show detailed information about one trestle task. |

### Workflow (8)

| Command | Description |
|---------|-------------|
| `/compliance-trestle:workflow-catalog-roundtrip` | Full catalog authoring workflow: generate, edit, and assemble. |
| `/compliance-trestle:workflow-profile-roundtrip` | Full profile authoring workflow: generate, edit, and assemble. |
| `/compliance-trestle:workflow-component-roundtrip` | Full component definition authoring workflow. |
| `/compliance-trestle:workflow-ssp-roundtrip` | Full SSP authoring workflow: generate, edit, and assemble. |
| `/compliance-trestle:workflow-assessment-roundtrip` | Full assessment workflow: create, split, edit, merge, and validate assessment plans and results. |
| `/compliance-trestle:workflow-poam-roundtrip` | Full POA&M workflow: create from assessment findings, track remediation, and manage milestones. |
| `/compliance-trestle:workflow-data-import` | Import data: OSCAL files with import, or CSV, XLSX, or XCCDF with tasks. |
| `/compliance-trestle:workflow-governance-setup` | Set up governance: workspace templates, config, and document-level enforcement. |

## Agents (10)

| Agent | Description |
|-------|-------------|
| **compliance-reviewer** | Reviews the workspace for completeness and gaps. Finds missing implementations, validation errors, and compliance posture issues. |
| **ssp-author** | Interactive assistant for SSP implementation responses, control by control. |
| **control-mapper** | Maps and traces controls across the OSCAL lifecycle: catalogs, profiles, SSPs, assessments, and POA&M. |
| **workspace-explorer** | Explores and explains workspace structure, model inventory, and relationships. |
| **assessment-reviewer** | Reviews assessment plans and results for completeness and alignment with the SSP. |
| **poam-manager** | Manages the POA&M lifecycle. Creates items from assessment findings. Tracks remediation. Manages milestones. |
| **validation-assistant** | Diagnoses and repairs trestle validation errors with guided troubleshooting. |
| **data-importer** | Imports and converts external data (CSV, XLSX, XCCDF, Tanium) into OSCAL. |
| **governance-enforcer** | Enforces governance policies: template compliance, header validation, and CI/CD setup. |
| **pipeline-architect** | Designs end-to-end compliance automation pipelines, persona ownership, and C2P bridging. |

## Skills (11)

| Skill | Description | Key Topics |
|-------|-------------|------------|
| **trestle-workspace** | Workspace structure, initialization, and directory conventions. | Init modes, config, common operations |
| **trestle-authoring-workflow** | Authoring workflows for all OSCAL model types. | Generate and assemble roundtrips. JSON split and merge for assessments and POA&M. |
| **trestle-oscal-models** | OSCAL model types, structure, and relationships. | 7 model types, element paths, file formats |
| **trestle-control-implementation** | Writing SSP control responses. | Worked AC-2 example, parameter precedence, multi-part controls, compensating controls, common mistakes |
| **trestle-assessment** | Assessment plans and results. | SAP and SAR creation, finding-to-control source traceability, XCCDF and Tanium integration |
| **trestle-poam** | POA&M lifecycle management. | Create from findings, remediation tracking, 30, 90, and 180-day milestone examples, split and merge patterns |
| **trestle-validation** | Validation and troubleshooting. | 5 validators, split file validation, CI/CD patterns, assessment and POA&M issues |
| **trestle-task-system** | Data conversion task framework. | CSV column reference, task testing workflow, troubleshooting, XCCDF, Tanium, and CIS tasks |
| **trestle-jinja-templating** | Jinja2 templating with OSCAL data. | Custom tags and filters, SSP context, lookup tables, assessment and POA&M report templates |
| **trestle-governance** | Document governance and template enforcement. | Security policy template example, global templates, versioned migration, governed folders, CI/CD |
| **trestle-compliance-pipeline** | End-to-end compliance automation pipeline. | Persona workflows, component-definition bridge, multi-repo coordination, C2P |

## Hooks

The plugin includes event hooks that start automatically:

| Hook | Event | Behavior |
|------|-------|----------|
| **Workspace Detection** | SessionStart | Detects a trestle workspace. Shows model inventory and available commands. |
| **Validation Reminder** | PostToolUse (Bash) | After `trestle assemble`, `trestle import`, `trestle merge`, `trestle create`, or `trestle split`, gives contextual guidance. |
| **OSCAL Edit Warning** | PreToolUse (Write/Edit) | Warns when you edit OSCAL JSON or YAML files directly. Prefer the authoring workflow. |

## Portable Agent Support

This repository also includes agent-portable instructions for Codex, Gemini CLI, OpenCode, Cursor, Devin Desktop, and generic desktop agents:

- `AGENTS.md`, `CURSOR.md`, `GEMINI.md`, `OPENCODE.md`
- `.cursor/skills/` native Cursor project skills (for example `/import-legacy-ssp`)
- `agent-skills/` portable Compliance Trestle and OSCAL document engineering skills
- `adapters/cursor/` and `adapters/generic-agent-package/` harness-specific docs and prompts
- `docs/AGENT-COMPATIBILITY.md` and `docs/PORTABLE-SKILLS.md`

## OSCAL Document Workbench

The OSCAL Document Workbench is in `plugins/document-transform/oscal-document-workbench/`.
It supplies command docs, scripts, templates, examples, and review workflow guidance.
Use it to convert legacy SSP, PDF, DOCX, Markdown, or TXT source material into source-traceable Compliance Trestle workspaces.

Start with:

- `docs/OSCAL-DOCUMENT-WORKBENCH.md`
- `docs/OSCAL-REVIEW-WORKFLOW.md`
- `docs/tutorials/legacy-ssp-to-oscal-with-agent.md`
- `examples/legacy-ssp-to-oscal/`

## Configuration

Per-project settings are in `.claude/compliance-trestle.local.md` (gitignored by default).

Run `/compliance-trestle:workspace-configure` to set or change settings:

| Setting | Default | Description |
|---------|---------|-------------|
| `auto_validate` | `true` | Remind the user to validate after assembly or import. |
| `default_catalog` | (empty) | Default catalog for authoring workflows. |
| `default_profile` | (empty) | Default profile for SSP generation. |
| `validation_level` | `normal` | `strict` treats warnings as errors. |
| `ssp_format` | `markdown` | Preferred SSP editing format. |

## Quick Start

```bash
# 1. Install compliance-trestle
pip install compliance-trestle

# 2. Initialize a workspace
/compliance-trestle:workspace-init

# 3. Import a catalog (for example, NIST 800-53)
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
