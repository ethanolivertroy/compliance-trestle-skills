# OSCAL SSP system characteristics template

Use this template to draft `system-characteristics` content from source-traceable legacy material.

## Required source map entries

| OSCAL target | Source requirement |
| --- | --- |
| `system-security-plan.system-characteristics.system-name` | source statement of system name |
| `system-security-plan.system-characteristics.description` | source description or `needs_review` |
| `system-security-plan.system-characteristics.security-sensitivity-level` | source classification/baseline or `needs_review` |
| `system-security-plan.system-characteristics.authorization-boundary.description` | source boundary text/diagram reference |

## Drafting pattern

```markdown
Field: system-name
Draft value: <exact or normalized system name>
Source IDs: SRC-001
Status: mapped
Reviewer notes: <normalization notes>
```

If the source is ambiguous, use `Status: needs_review` and do not guess.
