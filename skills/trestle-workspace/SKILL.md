---
name: trestle-workspace
description: >-
  Use this skill for Compliance Trestle workspace structure, init, and directory conventions.
  Use it for trestle workspaces, directory layout, .trestle config, and model directories.
  Use it to set up and organize an OSCAL compliance workspace.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Trestle Workspace Management

## Prerequisites

- Use Python 3.10-3.12. Compliance Trestle does not support Python 3.13 or later.
- Python 3.14 and later print a Pydantic V1 `UserWarning` on every trestle command.
  The warning is expected on unsupported versions. Python 3.11 and 3.12 do not print it.
- Install Compliance Trestle: `pip install compliance-trestle`

## Workspace Structure

A trestle workspace is a fixed directory layout for OSCAL compliance documents.
The layout is similar to a git repository.

### Core Directories

```
.
├── .trestle/              # Config dir (config.ini, cache, templates)
├── dist/                  # Assembled output files
│   ├── catalogs/
│   ├── profiles/
│   ├── component-definitions/
│   ├── system-security-plans/
│   ├── assessment-plans/
│   ├── assessment-results/
│   └── plan-of-action-and-milestones/
├── catalogs/              # Catalog source models
├── profiles/              # Profile source models
├── component-definitions/ # Component definition source models
├── system-security-plans/ # SSP source models
├── assessment-plans/      # Assessment plan source models
├── assessment-results/    # Assessment results source models
└── plan-of-action-and-milestones/  # POA&M source models
```

### Model Instance Layout

Each model instance is in its own subdirectory:

```
catalogs/
└── nist-800-53/
    └── catalog.json       # The actual OSCAL model file
```

## Initialization Modes

Run `trestle init` to create the workspace. Three modes are available:

| Mode | Flag | Creates | Use Case |
|------|------|---------|----------|
| Full | `--full` (default) | `.trestle/` + `dist/` + all model dirs | All workspace features: local models, API, governed docs |
| Local | `--local` | `.trestle/` + all model dirs (no `dist/`) | Local OSCAL model management only |
| GovDocs | `--govdocs` | `.trestle/` only | Document governance only |

## Key Rules

- Do not change file names or directory names that trestle creates.
- Do not mix JSON and YAML in one model directory.
- The `.trestle/` directory holds config files, caches, and templates.
- The `dist/` directory holds assembled and merged output files.
- Model files can be JSON (`.json`) or YAML (`.yaml`, `.yml`).
- The default format is JSON. YAML support is limited.

## Configuration

The workspace config is at `.trestle/config.ini`.
It stores task settings and other settings for trestle commands.

## Common Operations

- **Check if a workspace exists**: Look for the `.trestle/` directory.
- **List models**: Check subdirectories of model-type directories. Example: `catalogs/*/catalog.json`.
- **Validate workspace**: Run `trestle validate -a` to validate all models.
