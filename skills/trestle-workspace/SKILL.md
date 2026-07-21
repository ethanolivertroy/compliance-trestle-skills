---
name: trestle-workspace
description: >-
  Knowledge about Compliance Trestle workspace structure, initialization, and directory conventions.
  Use when users ask about trestle workspaces, directory layout, .trestle config, model directories,
  or how to set up and organize an OSCAL compliance workspace.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Trestle Workspace Management

## Prerequisites

- Python 3.9+ (3.11 or 3.12 recommended)
- On Python 3.14+, every trestle command prints a Pydantic V1 compatibility
  `UserWarning`. It is expected and non-blocking, but 3.11/3.12 avoids it entirely.
- Compliance Trestle installed: `pip install compliance-trestle`

## Workspace Structure

A trestle workspace is an opinionated directory structure (similar to git) that manages OSCAL compliance documents.

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

Each model instance lives in its own subdirectory:
```
catalogs/
└── nist-800-53/
    └── catalog.json       # The actual OSCAL model file
```

## Initialization Modes

`trestle init` creates the workspace. Three modes available:

| Mode | Flag | Creates | Use Case |
|------|------|---------|----------|
| Full | `--full` (default) | `.trestle/` + `dist/` + all model dirs | Full functionality: local models, API, governed docs |
| Local | `--local` | `.trestle/` + all model dirs (no `dist/`) | Local OSCAL model management only |
| GovDocs | `--govdocs` | `.trestle/` only | Document governance only |

## Key Rules

- File and directory names created by trestle MUST NOT be changed manually
- Within one model directory, do not mix JSON and YAML formats
- The `.trestle/` directory contains config files, caches, and templates
- The `dist/` directory holds assembled/merged output files
- Model files can be JSON (`.json`) or YAML (`.yaml`, `.yml`)
- Default format is JSON; YAML is supported on a best-effort basis

## Configuration

The workspace config lives at `.trestle/config.ini`. It can store task configurations and other settings used by trestle commands.

## Common Operations

- **Check if workspace exists**: Look for `.trestle/` directory
- **List models**: Check subdirectories of model-type directories (e.g., `catalogs/*/catalog.json`)
- **Validate workspace**: Run `trestle validate -a` to validate all models
