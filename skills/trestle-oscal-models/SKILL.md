---
name: trestle-oscal-models
description: >-
  Use this skill for OSCAL model types, their relationships, and how Compliance Trestle manages them.
  Use it for OSCAL documents, model types, catalogs, profiles, SSPs, and component definitions.
  Use it when users ask how compliance models relate to each other.
allowed-tools: Bash, Read, Glob, Grep
---

# OSCAL Model Types in Trestle

## The 7 OSCAL Model Types

| Model Type | CLI Name | Directory | Description |
|-----------|----------|-----------|-------------|
| Catalog | `catalog` | `catalogs/` | Set of security controls. Example: NIST 800-53 |
| Profile | `profile` | `profiles/` | Selection and change of controls from catalogs |
| Component Definition | `component-definition` | `component-definitions/` | How a component implements controls |
| System Security Plan | `system-security-plan` | `system-security-plans/` | Full system security documentation |
| Assessment Plan | `assessment-plan` | `assessment-plans/` | Plan for assessment of security controls |
| Assessment Results | `assessment-results` | `assessment-results/` | Results of a security assessment |
| POA&M | `plan-of-action-and-milestones` | `plan-of-action-and-milestones/` | Remediation tracking |

## Model Relationships

```
Catalog (controls)
    ↓ imports
Profile (selects + modifies controls)
    ↓ resolved profile catalog
Component Definition (how components implement controls)
    ↓ combined
System Security Plan (complete system documentation)
    ↓ assessed by
Assessment Plan → Assessment Results → POA&M
```

### The Catalog → Profile → SSP Chain

1. A **Catalog** defines controls. Example: NIST 800-53 has about 1000 controls.
2. A **Profile** imports controls from catalogs or profiles. It selects a subset. It can change parameters.
3. A **Resolved Profile Catalog** is the effective control set after profile changes.
4. A **Component Definition** describes how specific components address controls.
5. An **SSP** combines a profile and component definitions into implementation documentation.

### Profile Imports
A profile can import from:
- One or more catalogs
- One or more other profiles
- A mix of catalogs and profiles

Each import selects specific controls.
An import can change parameters.
An import can add content.

## Common OSCAL Fields

All models share:
- `uuid`: Unique identifier
- `metadata`: Title, version, last-modified, oscal-version, roles, parties
- `back-matter`: Resources, citations, attachments

## File Formats
- JSON (default): `.json`
- YAML: `.yaml` or `.yml`
- Within one model directory, do not mix formats

## Element Paths
Trestle uses dot-notation to address elements within models:
- `catalog.metadata`: The metadata of a catalog
- `catalog.groups.*.controls.*`: All controls in all groups
- `catalog.groups.0.controls.3`: Specific control (0-indexed)

Rules:
- Paths are relative to the file you operate on.
- Use the `*` wildcard for arrays. Quote it on *nix shells.
- You can skip array syntax: `catalog.controls.control` = `catalog.groups.controls.control`

## Trestle Operations on Models

| Operation | Command | Description |
|-----------|---------|-------------|
| Create | `trestle create -t <type> -o <name>` | Create a sample model with placeholder fields |
| Import | `trestle import -f <file> -o <name>` | Import an existing OSCAL file |
| Split | `trestle split -f <file> -e <elements>` | Split into sub-files |
| Merge | `trestle merge -e <elements>` | Reassemble split files |
| Describe | `trestle describe -f <file> -e <element>` | Inspect model structure |
| Validate | `trestle validate -f <file>` or `-t <type> -n <name>` or `-a` | Check model integrity |
| Assemble | `trestle assemble <type> -n <name>` | Combine split parts into dist/ |
| Replicate | `trestle replicate <type> -n <name> -o <new>` | Copy or rename a model |

### `trestle assemble` vs `trestle author *-assemble`

These two commands are different. Do not confuse them:

| Command | Input | Purpose |
|---------|-------|---------|
| `trestle assemble <type> -n <name>` | Split JSON/YAML sub-files | Combine files created by `trestle split` into one model in `dist/` |
| `trestle author <model>-assemble` (examples: `ssp-assemble`, `catalog-assemble`) | Edited markdown directory | Convert authored markdown back into an OSCAL JSON model |

If you generated markdown with `trestle author ssp-generate`, assemble it with
`trestle author ssp-assemble --markdown <md_dir> --output <ssp_name>`.
The generic `trestle assemble` command does not work on that markdown.

## SSP Special Concepts

- **This System** component: Default component in every SSP. The name is "This System".
- **By-Component responses**: Implementation prose organized by component.
- **Rules and Parameters**: These live in component definition properties. Trestle copies them into the SSP.
- **Implementation Status**: Tracked per component and per control.
- **Leveraged SSPs**: Inheritance from provider systems.

## Persona Ownership

Each OSCAL model type has a primary owner persona.
That persona authors and maintains the model:

| Model Type | Primary Persona | Trestle Commands | Notes |
|-----------|----------------|-----------------|-------|
| Catalog | Regulators | `catalog-generate`, `catalog-assemble` | Source of truth for controls |
| Profile | Compliance Officers / CISO | `profile-generate`, `profile-assemble` | Tailored baselines with org guidance |
| Component Definition (Service) | Control Providers (vendors) | `csv-to-oscal-cd`, `component-generate/assemble` | Maps controls to product rules |
| Component Definition (Validation) | Control Assessors (PVP vendors) | `csv-to-oscal-cd` (with `Check_Id`) | Maps rules to automated checks |
| System Security Plan | System Owners / CIO | `ssp-generate`, `ssp-assemble` | Combines profile + compdefs |
| Assessment Plan | Assessors / CISO | `create`, `split`, `merge` | Defines assessment scope |
| Assessment Results | Assessors / PVP tools | `xccdf-result-to-oscal-ar`, `tanium-result-to-oscal-ar` | Scan findings |
| POA&M | System Owners | `create`, `split`, `merge` | Remediation tracking |

In real organizations, one person can fill more than one persona role.
The ownership map is logical. It supports separation of duties.
It does not require one person per artifact.

## Component Definition: The Bridge Artifact

The component definition is a bridge in the OSCAL model chain.
It connects regulatory controls (governance layer) to automated assessment (technical layer).
It uses two distinct component types:

### Layer 1: Service Components (Control-to-Rule)

Service components declare which technology-specific rules implement a regulation control:
- Product vendors and service providers author them.
- Maps: **Control** (example: AC-2) --> **Rule** (example: `rule-account-types`) --> **Parameter** (example: `timeout=15min`)
- Create them with a CSV spreadsheet (`csv-to-oscal-cd` with `Component_Type=Service`).
- Add prose responses with markdown (`component-generate` / `component-assemble`).

### Layer 2: Validation Components (Rule-to-Check)

Validation components declare which PVP checks validate a rule:
- Assessment tool vendors and compliance engineers author them.
- Maps: **Rule** (example: `rule-account-types`) --> **Check_Id** (example: `test_github.GitHubOrgs.test_members_is_not_empty`)
- Create them with a CSV spreadsheet (`csv-to-oscal-cd` with `Component_Type=Validation` and a `Check_Id` column).
- C2P (Compliance-to-Policy) consumes them to bridge to runtime assessment.

### End-to-End Traceability

Together, the two layers create the full compliance automation chain:

```
Regulation Control (NIST AC-2)
    --> Service Rule (rule-account-types)
        --> Validation Check (test_github.GitHubOrgs.test_members)
            --> Assessment Result (pass/fail)
                --> Control Posture (satisfied/not-satisfied)
```

This chain supports automated posture computation.
Start from PVP results.
Map back through component definitions.
Then get the control-level status.

For full pipeline details, see the **trestle-compliance-pipeline** skill.

## Cross-References

- **trestle-workspace**: Workspace layout and where each model type lives on disk
- **trestle-authoring-workflow**: The generate → edit → assemble cycle for markdown-based authoring, including the `trestle author *-assemble` commands
- **trestle-control-implementation**: Writing control responses inside SSP and component-definition markdown
- **trestle-validation**: Validating models after create, import, split/merge, or assemble operations
- **trestle-compliance-pipeline**: How the model types flow through an end-to-end compliance automation pipeline
