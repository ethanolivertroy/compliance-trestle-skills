---
name: trestle-oscal-models
description: >-
  Knowledge about OSCAL model types, their relationships, and how they are managed in Compliance Trestle.
  Use when users ask about OSCAL documents, model types, catalogs, profiles, SSPs, component definitions,
  or how different compliance models relate to each other.
allowed-tools: Bash, Read, Glob, Grep
---

# OSCAL Model Types in Trestle

## The 7 OSCAL Model Types

| Model Type | CLI Name | Directory | Description |
|-----------|----------|-----------|-------------|
| Catalog | `catalog` | `catalogs/` | Collection of security controls (e.g., NIST 800-53) |
| Profile | `profile` | `profiles/` | Selection and modification of controls from catalogs |
| Component Definition | `component-definition` | `component-definitions/` | How a component implements controls |
| System Security Plan | `system-security-plan` | `system-security-plans/` | Complete system security documentation |
| Assessment Plan | `assessment-plan` | `assessment-plans/` | Plan for assessing security controls |
| Assessment Results | `assessment-results` | `assessment-results/` | Results of security assessment |
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

1. **Catalog** defines controls (e.g., NIST 800-53 has ~1000 controls)
2. **Profile** imports controls from catalogs/profiles, selects subset, modifies parameters
3. **Resolved Profile Catalog** is the effective set of controls after profile modifications
4. **Component Definition** describes how specific components address controls
5. **SSP** combines profile + component definitions into implementation documentation

### Profile Imports
A profile can import from:
- One or more catalogs
- One or more other profiles
- A mix of catalogs and profiles

Each import selects specific controls and can modify parameters and add content.

## Common OSCAL Fields

All models share:
- `uuid` - Unique identifier
- `metadata` - Title, version, last-modified, oscal-version, roles, parties
- `back-matter` - Resources, citations, attachments

## File Formats
- JSON (default): `.json`
- YAML: `.yaml` or `.yml`
- Within one model directory, don't mix formats

## Element Paths
Trestle uses dot-notation to address elements within models:
- `catalog.metadata` - The metadata of a catalog
- `catalog.groups.*.controls.*` - All controls in all groups
- `catalog.groups.0.controls.3` - Specific control (0-indexed)

Rules:
- Paths are relative to the file being operated on
- Use `*` wildcard for arrays (quote on *nix shells)
- Array syntax can be skipped: `catalog.controls.control` = `catalog.groups.controls.control`

## Trestle Operations on Models

| Operation | Command | Description |
|-----------|---------|-------------|
| Create | `trestle create -t <type> -o <name>` | Create bare-bones sample model |
| Import | `trestle import -f <file> -o <name>` | Import existing OSCAL file |
| Split | `trestle split -f <file> -e <elements>` | Decompose into sub-files |
| Merge | `trestle merge -e <elements>` | Reassemble split files |
| Describe | `trestle describe -f <file> -e <element>` | Inspect model structure |
| Validate | `trestle validate -f <file>` or `-t <type> -n <name>` or `-a` | Check model integrity |
| Assemble | `trestle assemble <type> -n <name>` | Combine split parts to dist/ |
| Replicate | `trestle replicate <type> -n <name> -o <new>` | Copy/rename model |

### `trestle assemble` vs `trestle author *-assemble`

These are two different commands that are easy to confuse:

| Command | Input | Purpose |
|---------|-------|---------|
| `trestle assemble <type> -n <name>` | Split JSON/YAML sub-files | Recombine files created by `trestle split` into a single model in `dist/` |
| `trestle author <model>-assemble` (e.g., `ssp-assemble`, `catalog-assemble`) | Edited markdown directory | Convert authored markdown back into an OSCAL JSON model |

If you generated markdown with `trestle author ssp-generate`, you must assemble it with
`trestle author ssp-assemble --markdown <md_dir> --output <ssp_name>`. Running the generic
`trestle assemble` on that markdown will not work.

## SSP Special Concepts

- **This System** component: Default component in every SSP (name: "This System")
- **By-Component responses**: Implementation prose organized by component
- **Rules and Parameters**: Embedded in component definition properties, propagated to SSP
- **Implementation Status**: Tracked per-component per-control
- **Leveraged SSPs**: Inheritance from provider systems

## Persona Ownership

Each OSCAL model type has a primary owner persona responsible for authoring and maintaining it:

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

In real organizations, one person may fill multiple persona roles. The ownership mapping
is logical (separation of duties), not necessarily physical (one person per artifact).

## Component Definition: The Bridge Artifact

The component definition plays a unique bridging role in the OSCAL model chain. It connects
regulatory controls (governance layer) to automated assessment (technical layer) through
two distinct component types:

### Layer 1 — Service Components (Control-to-Rule)

Service components declare which technology-specific rules implement a regulation control:
- Authored by product vendors and service providers
- Maps: **Control** (e.g., AC-2) --> **Rule** (e.g., `rule-account-types`) --> **Parameter** (e.g., `timeout=15min`)
- Created via CSV spreadsheet (`csv-to-oscal-cd` with `Component_Type=Service`)
- Prose responses added via markdown (`component-generate` / `component-assemble`)

### Layer 2 — Validation Components (Rule-to-Check)

Validation components declare which PVP checks validate a rule:
- Authored by assessment tool vendors and compliance engineers
- Maps: **Rule** (e.g., `rule-account-types`) --> **Check_Id** (e.g., `test_github.GitHubOrgs.test_members_is_not_empty`)
- Created via CSV spreadsheet (`csv-to-oscal-cd` with `Component_Type=Validation` and `Check_Id` column)
- Consumed by C2P (Compliance-to-Policy) to bridge to runtime assessment

### End-to-End Traceability

Together, the two layers create the full compliance automation chain:

```
Regulation Control (NIST AC-2)
    --> Service Rule (rule-account-types)
        --> Validation Check (test_github.GitHubOrgs.test_members)
            --> Assessment Result (pass/fail)
                --> Control Posture (satisfied/not-satisfied)
```

This traceability enables automated posture computation: given PVP results, map
backward through component definitions to determine control-level compliance status.

For full pipeline details, see the **trestle-compliance-pipeline** skill.

## Cross-References

- **trestle-workspace**: Workspace layout and where each model type lives on disk
- **trestle-authoring-workflow**: The generate → edit → assemble cycle for markdown-based authoring, including the `trestle author *-assemble` commands
- **trestle-control-implementation**: Writing control responses inside SSP and component-definition markdown
- **trestle-validation**: Validating models after create, import, split/merge, or assemble operations
- **trestle-compliance-pipeline**: How the model types flow through an end-to-end compliance automation pipeline
