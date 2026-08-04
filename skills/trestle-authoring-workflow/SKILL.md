---
name: trestle-authoring-workflow
description: >-
  Use this skill for the Compliance Trestle authoring workflow.
  The workflow is the generate-edit-assemble cycle that converts OSCAL documents to markdown and back.
  Use it for authoring catalogs, profiles, SSPs, or component definitions.
  Use it for editing control markdown, YAML headers, or the roundtrip workflow between JSON and markdown.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Trestle Authoring Workflow

## The Generate-Edit-Assemble Cycle

Trestle authoring tools convert OSCAL JSON to markdown for human editing.
Then they convert markdown back to JSON:

```
JSON (OSCAL) → generate → Markdown (edit) → assemble → JSON (OSCAL)
```

This cycle continues.
After the first generate, edit markdown and assemble again.

## Author Commands by Model Type

### Catalog Authoring
- `trestle author catalog-generate --name <catalog> --output <md_dir>` → markdown per control
- `trestle author catalog-assemble --markdown <md_dir> --output <catalog>` → JSON catalog

### Profile Authoring
- `trestle author profile-generate --name <profile> --output <md_dir>` → markdown with profile additions
- `trestle author profile-assemble --markdown <md_dir> --output <profile>` → JSON profile
- `trestle author profile-resolve --name <profile> --output <resolved>` → resolved profile catalog

### Component Definition Authoring
- `trestle author component-generate --name <compdef> --output <md_dir>` → markdown per component/control
- `trestle author component-assemble --markdown <md_dir> --output <compdef>` → JSON component-definition

### SSP Authoring
- `trestle author ssp-generate --profile <profile> --compdefs <comp1,comp2> --output <md_dir>` → markdown per control
- `trestle author ssp-assemble --markdown <md_dir> --output <ssp>` → JSON SSP
- `trestle author ssp-filter --name <ssp> --profile <profile> --output <filtered>` → filtered SSP

## Markdown Structure

### Control Markdown File
Each control gets its own `.md` file with:
1. **YAML header**: metadata, parameters, properties
2. **Control title**: `# control-id - [Group Title] Control Title`
3. **Control Statement**: `## Control Statement` with labeled parts
4. **Control guidance**: `## Control guidance`
5. **Additional sections**: Implementation responses, component sections

### YAML Header Tags (x-trestle-*)
| Tag | Purpose |
|-----|---------|
| `x-trestle-set-params` | Parameter values for the control |
| `x-trestle-global` | Global metadata (sort-id, profile title) |
| `x-trestle-sections` | Map of section short names to display names |
| `x-trestle-add-props` | Properties to add to the control |
| `x-trestle-comp-def-rules` | Rules from component definitions |
| `x-trestle-comp-def-rules-param-vals` | Rule parameter values |
| `x-trestle-inherited-props` | Properties inherited from upstream |
| `x-trestle-leveraging-comp` | Leveraged component information |
| `x-trestle-statement` | Statement-level metadata |

### Parameter Handling

**In catalog markdown** (`x-trestle-set-params`):
```yaml
x-trestle-set-params:
  ac-1_prm_1:
    values:
      - organization-defined value
    label: descriptive label
```

**In profile markdown** (adds `profile-values`):
```yaml
x-trestle-set-params:
  ac-1_prm_1:
    values:
      - catalog value
    profile-values:
      - profile-specific value
```

**In SSP markdown** (adds `ssp-values`):
```yaml
x-trestle-set-params:
  ac-1_prm_1:
    values:
      - resolved value
    ssp-values:
      - ssp-specific value
```

## Key Options

| Option | Commands | Purpose |
|--------|----------|---------|
| `--set-parameters` | catalog-assemble, profile-assemble | Apply parameter changes from YAML header |
| `--overwrite-header-values` | all -generate | Overwrite existing header values with provided YAML |
| `--force-overwrite` | all -generate | Erase existing markdown before regenerating |
| `--yaml` / `-y` | all -generate | Provide external YAML header to merge |
| `--version` | all -assemble | Set version in assembled model |
| `--regenerate` | all -assemble | Generate new UUIDs |
| `--sections` | profile-assemble | Define allowed sections |
| `--required-sections` | profile-assemble | Sections that must be present |
| `--compdefs` | ssp-generate | Comma-separated component definitions |

## Implementation Status Values
Controls track implementation status with these values:
- `implemented`: Fully implemented
- `partial`: Partially implemented
- `planned`: Implementation is planned
- `alternative`: Alternative implementation
- `not-applicable`: Control is not applicable

## Control Origination Values
- `organization`: Organization-level
- `system-specific`: System-specific
- `customer-configured`: Customer configured
- `customer-provided`: Customer provided
- `inherited`: Inherited from another system

## CI/CD Integration
Use the authoring tools in CI/CD pipelines:
- Assemble commands write output only if content changed. This prevents extra triggers.
- `--set-parameters` limits what can change during automated assembly.
- `--required-sections` and `--allowed-sections` check document structure.
- Individual control markdown files support fine-grained git tracking.

## Multi-Repository Coordination

Large organizations split OSCAL artifacts across multiple Git repositories.
The split follows ownership boundaries.
Trestle authoring tools support this through CI/CD-driven propagation.

### Repository Topology

```
catalog-repo (Regulators)
    |
    v  imports
profile-repo (Compliance Officers)
    |
    v  references
compdef-repo (Vendors / Control Providers)
    |
    v  combined into
ssp-repo (System Owners)
```

Each repository contains its own trestle workspace (`.trestle/` directory).
Each repository manages artifacts independently with its own CI/CD pipeline.

### Change Propagation Pattern

When an upstream artifact changes:

1. Upstream repo merges markdown edits to main.
2. CI/CD runs `trestle author *-assemble` to rebuild OSCAL JSON.
3. If JSON changed, CI/CD creates a PR in each downstream repository.
4. Downstream owners review the PR, which pulls the updated upstream artifact.
5. On merge, the downstream CI/CD assembles its own artifacts with the new input.

This pattern uses `repository_dispatch` events (GitHub Actions) or cross-project triggers
(GitLab CI) to connect repositories.

### When to Use Multi-Repo vs Single-Repo

| Factor | Single Repo | Multi-Repo |
|--------|-------------|------------|
| Team size | Small (1-5 people) | Multiple teams or organizations |
| Ownership | Same team owns all artifacts | Different teams own different artifacts |
| Release cadence | Artifacts change together | Independent versioning needed |
| Access control | Same permissions for all | Different access per artifact type |
| Complexity | Simpler setup and maintenance | Clearer ownership split |

**Start with a single repo.** Split when ownership boundaries emerge or when
independent versioning is required.

## Two-Phase Component Definition Authoring

Component definitions combine structured rule data with narrative prose.
Trestle supports a two-phase authoring pattern.
Use the best tool for each type of content.

### Phase 1: Rules with CSV Spreadsheet

```bash
# CSV contains structured mappings: rules, parameters, control associations
trestle task csv-to-oscal-cd
```

The CSV captures:
- `Rule_Id`, `Rule_Description`: the technical rule
- `Control_Id_List`: which regulation controls this rule implements
- `Parameter_Id`, `Parameter_Value_Alternatives`: configurable parameters
- `Component_Type`: `Service` (control-to-rule) or `Validation` (rule-to-check)

Vendors manage this CSV in spreadsheet tools.
It is committed to Git.
The `csv-to-oscal-cd` task converts it to OSCAL JSON.

### Phase 2: Responses with Markdown

```bash
# Generate markdown from the Phase 1 component definition
trestle author component-generate --name my-service --output md_compdefs/my-service

# Markdown shows rules (read-only) + editable prose sections
# Edit: write implementation descriptions per control per component
# Then reassemble
trestle author component-assemble --markdown md_compdefs/my-service --output my-service
```

The markdown includes:
- Read-only rules section (from Phase 1 CSV data)
- Read-only control description and guidance (from catalog/profile)
- Editable implementation response sections (prose describing HOW the control is met)
- Implementation status (`implemented`, `partial`, `planned`, and related values)

### Why Two Phases?

- **Structured data** (rules, parameters, mappings) is best managed in spreadsheets.
- **Narrative prose** (implementation descriptions) is best edited as markdown.
- Different personas can own each phase. Security engineers write rules. Product owners write prose.
- Phase 1 can be automated from tooling. Phase 2 needs human judgment.

## Git-Based Authoring Workflow

Trestle authoring tools support Git-based collaboration with CI/CD automation.

### PR-Based Review Cycle

1. Author edits markdown on a feature branch.
2. Opens a PR for peer review.
3. CI/CD runs `trestle validate` on the PR to catch errors early.
4. Reviewers approve. The PR is merged to main.
5. CI/CD on main runs `trestle author *-assemble` to rebuild OSCAL JSON.
6. If JSON changed, CI/CD commits the updated JSON. It can also trigger downstream repos.

### Conditional Write Behavior

Assemble commands write output only if content changed. This prevents:
- Extra git commits (no-op JSON changes)
- Infinite CI/CD trigger loops between repositories
- Misleading git history with empty diffs

### Branch Protection Recommendations

| Branch | Protection | Who Can Merge |
|--------|-----------|---------------|
| `main` | Require PR review + CI/CD pass | Artifact owner (per persona) |
| Feature branches | No protection | Any contributor |

Individual control markdown files support fine-grained git tracking.
Reviewers can see which controls changed in a PR diff.

## Models Without Author Commands

Not all OSCAL models have `trestle author` generate or assemble commands.
The following models use a **JSON-based workflow** instead:

| Model | `trestle author` Support | Workflow |
|-------|--------------------------|----------|
| Catalog | `catalog-generate` / `catalog-assemble` | Markdown roundtrip |
| Profile | `profile-generate` / `profile-assemble` | Markdown roundtrip |
| Component Definition | `component-generate` / `component-assemble` | Markdown roundtrip |
| SSP | `ssp-generate` / `ssp-assemble` | Markdown roundtrip |
| **Assessment Plan** | **None** | `create → split → edit → merge → validate` |
| **Assessment Results** | **None** | `create → split → edit → merge → validate` |
| **POA&M** | **None** | `create → split → edit → merge → validate` |

### JSON-Based Workflow

For assessment plans, assessment results, and POA&M:

```bash
# 1. Create a new model with placeholder fields
trestle create -t <model-type> -o <name>

# 2. Split into editable sections
trestle split -f <model-file>.json -e '<model-type>.<element1>,<model-type>.<element2>'

# 3. Edit the resulting JSON files directly

# 4. Merge sections back together
trestle merge -e '<model-type>.<element1>,<model-type>.<element2>'

# 5. Validate the final model
trestle validate -t <model-type> -n <name>
```

For detailed workflows, see the `trestle-assessment` skill (assessment plans and results) and the `trestle-poam` skill (plan of action and milestones).
