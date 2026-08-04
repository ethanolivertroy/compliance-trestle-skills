---
name: trestle-control-implementation
description: >-
  Use this skill to write control implementation responses, rules, parameters, and component-level responses.
  Use it for inheritance and leveraged SSPs in Compliance Trestle.
  Use it for control responses, implementation status, rules, parameters, component definitions,
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

Each control statement part gets a response from each component:

1. **Named Components** (from component-definitions): Have rules, parameters, status
2. **This System** component: Overall system-level response (always present)

> **First run without component definitions:** If you run `ssp-generate` without
> `--compdefs`, the generated markdown contains only `This System` sections.
> Named component sections such as `Identity Provider` appear only after you load
> component definitions and pass them with `--compdefs`. This result is expected.
> It is not an error.

### Adding Implementation Prose
Replace the HTML comment placeholders with implementation text:
```markdown
### My Component
This component implements access control policy by...
```

## Rules and Parameters

### Rules
Rules come from component definitions. Rules are **read-only** in SSP markdown:
```yaml
x-trestle-comp-def-rules:
  Component Name:
    - name: rule-id
      description: What the rule checks
```

### Rule Parameters
You can override parameter values for rules in the SSP:
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

Set status per component with these values:
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
- `organization`: Organization-wide policy or procedure
- `system-specific`: Specific to this system
- `customer-configured`: Customer configures provider capability
- `customer-provided`: Customer provides the implementation
- `inherited`: Inherited from provider system

## Profile-Level Control Additions

Profiles can add sections to controls:
```yaml
x-trestle-sections:
  guidance: Guidance
  implgdn: Implementation Guidance
  expevid: Expected Evidence
```

These sections appear in the markdown and you can edit them:
```markdown
## Implementation Guidance
Organization-specific implementation guidance here.

## Expected Evidence
Evidence required to demonstrate implementation.
```

## Best Practices

1. **Be specific**: Name actual system components, tools, and processes.
2. **Address each part**: Give a response for every statement part.
3. **Set parameters**: Replace `<REPLACE_ME>` placeholders with actual values.
4. **Set status honestly**: Use `partial` or `planned` when that is the true state.
5. **Document inheritance**: Describe what is inherited and what is local.
6. **Use component definitions**: Put reusable compliance content in component-definitions.
7. **Use CI/CD**: Run assemble in pipelines to validate changes automatically.

## Worked Example: Writing AC-2 Account Management

This example assumes you passed a component definition with an `Identity Provider`
component to `ssp-generate` with `--compdefs`.
Without it, only the `This System` sections appear.

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

Parameter values flow through three levels.
Each level can override the previous level:

| Level | Field | Source | Purpose |
|-------|-------|--------|---------|
| 1. Catalog | `values` | Catalog parameter definition | Default or suggested value |
| 2. Profile | `profile-values` | Profile `set-parameters` | Baseline-specific tailoring |
| 3. SSP | `ssp-values` | SSP control markdown header | System-specific implementation value |

**The SSP-level `ssp-values` always wins.**
If `ssp-values` is set, it overrides `profile-values` and catalog `values`.
If `ssp-values` is empty, Trestle uses the profile value.
If the profile does not set a value, Trestle uses the catalog default.

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

OSCAL controls often have statement parts (a, b, c).
Some controls also have sub-parts (a.1, a.2).
Each part maps to a markdown structure.

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

- Give a response for every statement part and every component. If a part does not apply, say the part is not applicable to that component.
- Control statement text, guidance, and objective sections are **informational**. Do not edit them.
- Only the sections below the horizontal rule (`______________________________________________________________________`) accept implementation prose.

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

3. **Reference the POA&M entry** if one exists for tracking the gap.

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| Leaving `<!-- Add control implementation -->` comments | Assemble keeps them as empty content. Auditors see blank responses | Replace every placeholder with actual prose. Or remove it |
| Wrong YAML indentation in headers | Assemble fails with a YAML parse error | Use 2-space indentation consistently. Never use tabs |
| Missing `ssp-values` when values are required | Parameters resolve to catalog defaults. Those defaults can be vague placeholders | Set explicit `ssp-values` for every parameter |
| Writing generic responses like "The system implements this control" | Fails ATO review. Assessors need specific detail | Reference specific tools, processes, configurations, and responsible roles |
| Not addressing every statement part separately | Assemble can drop unaddressed parts without a warning | Add a response for each part per component. "Not applicable to this component" is valid |
| Confusing `values` vs `ssp-values` | Assembled SSP uses the wrong parameter value | `values` = catalog default. `ssp-values` = what this system actually uses |
| Editing content above the horizontal rule | The next generate overwrites the changes | Only edit content below the `______________________________________________________________________` divider |

## Where Rules Come From

Rules in SSP markdown under `x-trestle-comp-def-rules` come from the component definition authoring chain.
Do not author rules in the SSP.

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

The rules section in SSP control markdown is populated from component definitions during `ssp-generate`.
Edits to rules in SSP markdown have no effect.
The next `ssp-generate` run overwrites them.

**To change a rule**: Edit the source component definition in CSV or component markdown.
Reassemble it.
Then regenerate the SSP.

### To Add New Rules

1. Add the rule to the component definition CSV.
2. Run `trestle task csv-to-oscal-cd` to rebuild the component definition.
3. Run `trestle author component-generate` and write the prose response.
4. Run `trestle author component-assemble`.
5. Run `trestle author ssp-generate` to pull the new rule into SSP markdown.

For the full two-phase component definition workflow, see **trestle-compliance-pipeline**.

## Cross-References

- **trestle-authoring-workflow**: The full generate → edit → assemble cycle for SSP control implementation
- **trestle-validation**: Diagnosing and fixing assemble errors, YAML parse failures, and schema validation issues
- **trestle-governance**: Checking consistent response structure and required headings across control implementations
- **trestle-compliance-pipeline**: End-to-end pipeline including the rules supply chain and two-phase component definition authoring
