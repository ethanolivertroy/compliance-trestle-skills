---
name: trestle-control-implementation
description: >-
  Knowledge about writing control implementation responses, rules, parameters, component-level
  responses, inheritance, and leveraged SSPs in Compliance Trestle. Use when users ask about
  writing control responses, implementation status, rules, parameters, component definitions,
  SSP implementation details, or compliance documentation content.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# Control Implementation in Trestle

## Writing Control Responses

### SSP Control Markdown Structure

Each control markdown file in an SSP has this structure:

```markdown
---
x-trestle-set-params:
  ac-1_prm_1:
    values:
      - organization-defined value
    ssp-values:
      - actual SSP value
x-trestle-comp-def-rules:
  My Component:
    - name: rule-ac-1
      description: Ensure access control policy exists
x-trestle-comp-def-rules-param-vals:
  My Component:
    - name: rule-param-1
      values:
        - default value
      ssp-values:
        - SSP override value
---

# ac-1 - [Access Control] Policy and Procedures

## Control Statement
[Control statement text with {{ insert: param, ac-1_prm_1 }} placeholders]

## Control guidance
[Guidance text]

______________________________________________________________________

## Implementation for part a.

### My Component

<!-- Add control implementation description here for part a. -->
Implementation prose for component addressing part a.

#### Rules:
  - rule-ac-1

#### Implementation Status: implemented

### This System

<!-- Add control implementation description here for part a. -->
Implementation prose for the overall system addressing part a.

#### Implementation Status: partial
```

## Component-Level Responses

Each control statement part gets responses from each component:

1. **Named Components** (from component-definitions): Have rules, parameters, status
2. **This System** component: Overall system-level response (always present)

> **First run without component definitions:** If you run `ssp-generate` without
> `--compdefs` (or before any component-definitions exist in the workspace), the
> generated markdown will only contain `This System` sections. Named component
> sections such as `Identity Provider` in the examples below only appear after
> component definitions are loaded and passed via `--compdefs`. This is expected,
> not an error.

### Adding Implementation Prose
Replace the HTML comment placeholders with actual implementation text:
```markdown
### My Component
This component implements access control policy by...
```

## Rules and Parameters

### Rules
Rules come from component definitions and are **read-only** in SSP markdown:
```yaml
x-trestle-comp-def-rules:
  Component Name:
    - name: rule-id
      description: What the rule checks
```

### Rule Parameters
Parameters for rules can have values overridden in SSP:
```yaml
x-trestle-comp-def-rules-param-vals:
  Component Name:
    - name: param-name
      values:
        - component default
      ssp-values:
        - SSP override
```

## Implementation Status

Set per-component using these values:
| Status | Meaning |
|--------|---------|
| `implemented` | Fully implemented |
| `partial` | Partially implemented |
| `planned` | Implementation planned |
| `alternative` | Alternative implementation exists |
| `not-applicable` | Not applicable to this component |

In markdown: `#### Implementation Status: implemented`

## Inheritance and Leveraged SSPs

### Leveraged SSPs
When a system inherits controls from a provider:

```markdown
## This System: Component Name

### Provided Statement Description
Description of what the provider system provides.

### Responsibility Statement Description
Description of customer responsibilities.

### Satisfied Statement Description
How the inheriting system satisfies its responsibilities.
```

### Control Origination
Tracks where control implementation comes from:
- `organization` - Organization-wide policy/procedure
- `system-specific` - Specific to this system
- `customer-configured` - Customer configures provider capability
- `customer-provided` - Customer provides the implementation
- `inherited` - Inherited from provider system

## Profile-Level Control Additions

Profiles can add sections to controls:
```yaml
x-trestle-sections:
  guidance: Guidance
  implgdn: Implementation Guidance
  expevid: Expected Evidence
```

These sections appear in the markdown and can be edited:
```markdown
## Implementation Guidance
Organization-specific implementation guidance here.

## Expected Evidence
Evidence required to demonstrate implementation.
```

## Best Practices

1. **Be specific**: Reference actual system components, tools, and processes
2. **Address each part**: Ensure every statement part has a response
3. **Set parameters**: Replace `<REPLACE_ME>` placeholders with actual values
4. **Track status honestly**: Use `partial` or `planned` when appropriate
5. **Document inheritance**: Clearly describe what is inherited vs. locally implemented
6. **Use component definitions**: Define reusable compliance content in component-definitions
7. **Leverage CI/CD**: Use assemble in pipelines to validate changes automatically

## Worked Example: Writing AC-2 Account Management

This example assumes a component definition providing an `Identity Provider`
component was passed to `ssp-generate` via `--compdefs`. Without it, only the
`This System` sections appear.

### Before: Generated Markdown (Unfilled)

```markdown
---
x-trestle-set-params:
  ac-2_prm_1:
    values:
      - organization-defined account types
    ssp-values:
---

# ac-2 - Account Management

## Control Statement

...

______________________________________________________________________

## Implementation for part a.

### Identity Provider

<!-- Add control implementation description here for part a. -->

#### Implementation Status: planned

### This System

<!-- Add control implementation description here for part a. -->

#### Implementation Status: planned
```

### After: Filled-In Implementation

```markdown
---
x-trestle-set-params:
  ac-2_prm_1:
    values:
      - organization-defined account types
    ssp-values:
      - privileged, non-privileged, system, service, and temporary accounts
---

# ac-2 - Account Management

## Control Statement

...

______________________________________________________________________

## Implementation for part a.

### Identity Provider

The Identity Provider (IdP) manages all user account types including privileged,
non-privileged, and service accounts. Account provisioning is handled through
the IdP's administrative console with SCIM integration to downstream systems.

#### Rules:
  - rule-ac-2-account-types

#### Implementation Status: implemented

### This System

The system integrates with the organization's Identity Provider for account
lifecycle management. Local service accounts are managed through
infrastructure-as-code templates with mandatory approval workflows.

#### Implementation Status: implemented

## Implementation for part b.

### Identity Provider

Account managers are designated through the IdP's delegation model. Each
organizational unit has a primary and backup account manager assigned in the
IdP administrative hierarchy.

#### Implementation Status: implemented

### This System

System-level account managers are documented in the System Security Plan
Appendix A and are drawn from the operations team as designated by the ISSO.

#### Implementation Status: implemented
```

## Parameter Precedence

Parameter values flow through three levels, with each level able to override the previous:

| Level | Field | Source | Purpose |
|-------|-------|--------|---------|
| 1. Catalog | `values` | Catalog parameter definition | Default/suggested value |
| 2. Profile | `profile-values` | Profile `set-parameters` | Baseline-specific tailoring |
| 3. SSP | `ssp-values` | SSP control markdown header | System-specific implementation value |

**The SSP-level `ssp-values` always wins.** If `ssp-values` is set, it overrides both `profile-values` and catalog `values`. If `ssp-values` is empty, the profile value is used. If the profile doesn't set a value, the catalog default applies.

Example showing the same parameter at all three levels:
```yaml
# Catalog defines: ac-1_prm_1 values: ["organization-defined frequency"]
# Profile sets: profile-values: ["annually"]
# SSP overrides:
x-trestle-set-params:
  ac-1_prm_1:
    values:
      - organization-defined frequency
    profile-values:
      - annually
    ssp-values:
      - at least every 365 days or upon policy change
```

In the assembled SSP, the resolved value is `at least every 365 days or upon policy change`.

## Handling Multi-Part Controls

OSCAL controls often have statement parts (a, b, c...) and sometimes sub-parts (a.1, a.2). Each maps to a specific markdown structure.

### Statement Parts

Each lettered part gets its own `## Implementation for part X.` heading:
```markdown
## Implementation for part a.
### My Component
[Response for part a]

## Implementation for part b.
### My Component
[Response for part b]
```

### Sub-Parts

Nested sub-parts use extended identifiers:
```markdown
## Implementation for part a.1.
### My Component
[Response for sub-part a.1]
```

### Which Parts Need Responses

- **Every statement part must have a response** for each component — even if only to say the part is not applicable to that component
- Control statement text, guidance, and objective sections are **informational** and should not be edited
- Only the sections below the horizontal rule (`______________________________________________________________________`) accept implementation prose

## Compensating Controls

When a control requirement cannot be met as stated, document a compensating control:

1. **Set implementation status to `alternative`**:
   ```markdown
   #### Implementation Status: alternative
   ```

2. **Describe the compensating control** in the implementation prose:
   ```markdown
   ### This System
   The system cannot implement centralized session termination as specified
   due to architectural constraints in the legacy middleware layer. As a
   compensating control, the system enforces aggressive idle timeouts
   (15 minutes) at the application layer and requires re-authentication
   for all privileged operations. This compensating control was approved
   by the AO on 2024-06-15 (see POA&M item PM-2024-042).
   ```

3. **Reference the POA&M entry** if one exists for tracking the gap

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Leaving `<!-- Add control implementation -->` comments | Assemble silently includes them as empty content — auditors see blank responses | Replace every placeholder with actual prose or remove it |
| Wrong YAML indentation in headers | Assemble fails with a YAML parse error | Use 2-space indentation consistently, never tabs |
| Missing `ssp-values` when values are required | Parameters resolve to catalog defaults which may be vague placeholders | Set explicit `ssp-values` for every parameter |
| Writing generic responses like "The system implements this control" | Fails ATO review — assessors need specific detail | Reference specific tools, processes, configurations, and responsible roles |
| Not addressing every statement part separately | Assemble may silently drop unaddressed parts | Add a response (even "Not applicable to this component") for each part per component |
| Confusing `values` vs `ssp-values` | Assembled SSP uses the wrong parameter value | `values` = catalog default; `ssp-values` = what this system actually uses |
| Editing content above the horizontal rule | Changes are overwritten on the next generate | Only edit content below the `______________________________________________________________________` divider |

## Where Rules Come From

Rules that appear in SSP markdown (under `x-trestle-comp-def-rules`) originate from the
component definition authoring supply chain — they are **not authored in the SSP**.

### The Rules Supply Chain

```
CSV spreadsheet (vendor-authored rules, parameters, control mappings)
    --> trestle task csv-to-oscal-cd (produces component-definition JSON)
        --> trestle author component-generate (produces component markdown with rules + editable prose)
            --> Edit markdown: write implementation responses
                --> trestle author component-assemble (merges prose into component-definition JSON)
                    --> trestle author ssp-generate --compdefs ... (pulls rules into SSP markdown)
```

### Rules Are Read-Only in SSP Markdown

The rules section in SSP control markdown is populated from component definitions during
`ssp-generate`. Editing rules directly in SSP markdown has no effect — they will be
overwritten on the next `ssp-generate` run.

**To change a rule**: Edit the source component definition (CSV or component markdown),
reassemble it, then regenerate the SSP.

### To Add New Rules

1. Add the rule to the component definition CSV
2. Run `trestle task csv-to-oscal-cd` to rebuild the component definition
3. Run `trestle author component-generate` and write the prose response
4. Run `trestle author component-assemble`
5. Run `trestle author ssp-generate` to pull the new rule into SSP markdown

For the full two-phase component definition workflow, see **trestle-compliance-pipeline**.

## Cross-References

- **trestle-authoring-workflow**: The full generate → edit → assemble cycle for SSP control implementation
- **trestle-validation**: Diagnosing and fixing assemble errors, YAML parse failures, and schema validation issues
- **trestle-governance**: Enforcing consistent response structure and required headings across control implementations
- **trestle-compliance-pipeline**: End-to-end pipeline including the rules supply chain and two-phase component definition authoring
