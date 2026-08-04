---
name: trestle-poam
description: >-
  Use this skill for the OSCAL Plan of Action and Milestones (POA&M) model in Compliance Trestle.
  Use it for POA&M, plan of action, milestones, remediation, findings tracking, and risk management.
  Use it to manage security finding remediation workflows.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# OSCAL Plan of Action and Milestones (POA&M) in Trestle

## Overview

The POA&M model tracks security findings that need remediation.
A POA&M records:
- What weaknesses were found
- What risks they pose
- What actions will remediate them
- When remediation milestones are due

## POA&M Structure

```json
{
  "plan-of-action-and-milestones": {
    "uuid": "...",
    "metadata": {
      "title": "System POA&M",
      "version": "1.0"
    },
    "import-ssp": { "href": "#..." },
    "system-id": { "id": "..." },
    "poam-items": [
      {
        "uuid": "...",
        "title": "AC-1 Finding",
        "description": "Access control policy not fully documented",
        "related-observations": [],
        "related-risks": [],
        "origins": [],
        "remarks": "..."
      }
    ],
    "local-definitions": {
      "components": [],
      "inventory-items": []
    },
    "observations": [],
    "risks": []
  }
}
```

## Key Components

### POA&M Items

Each POA&M item is a finding that needs remediation:

| Field | Purpose |
|-------|---------|
| `title` | Short description of the finding |
| `description` | Detailed description of the weakness |
| `related-observations` | Links to observations from assessment |
| `related-risks` | Links to associated risk entries |
| `origins` | Who or what identified this item |
| `remarks` | Extra notes or context |

### Observations

Observations give evidence and context for findings:

```json
{
  "uuid": "...",
  "title": "AC-1 Observation",
  "description": "Policy document was last updated 3 years ago",
  "methods": ["EXAMINE", "INTERVIEW"],
  "types": ["finding"],
  "subjects": [{ "subject-uuid": "...", "type": "component" }],
  "collected": "2024-01-15T00:00:00Z"
}
```

### Assessment Methods
| Method | Description |
|--------|-------------|
| `EXAMINE` | Review of documentation, records, configurations |
| `INTERVIEW` | Discussion with personnel |
| `TEST` | Hands-on testing of systems and controls |

### Risks

Risk entries document the risk associated with findings:

```json
{
  "uuid": "...",
  "title": "Outdated Access Control Policy",
  "description": "...",
  "statement": "Without current policy, access controls may not meet requirements",
  "status": "open",
  "characterizations": [
    {
      "origin": {},
      "facets": [
        { "name": "likelihood", "value": "moderate", "system": "..." },
        { "name": "impact", "value": "high", "system": "..." }
      ]
    }
  ],
  "mitigating-factors": [],
  "remediations": [
    {
      "uuid": "...",
      "lifecycle": "planned",
      "title": "Update access control policy",
      "description": "...",
      "required-assets": [],
      "tasks": [
        {
          "uuid": "...",
          "type": "milestone",
          "title": "Draft updated policy",
          "timing": {
            "within-date-range": {
              "start": "2024-02-01",
              "end": "2024-03-01"
            }
          }
        }
      ]
    }
  ]
}
```

### Risk Status Values
| Status | Meaning |
|--------|---------|
| `open` | The finding is active. Remediation is not complete |
| `investigating` | Under investigation |
| `remediating` | Remediation is in progress |
| `deviation-requested` | Request for deviation or risk acceptance |
| `deviation-approved` | Deviation approved (risk accepted) |
| `closed` | The finding is remediated and verified |

### Remediation Lifecycle
| Lifecycle | Meaning |
|-----------|---------|
| `recommendation` | Suggested action |
| `planned` | Approved remediation plan |
| `completed` | Remediation action completed |

## Workspace Location

```
plan-of-action-and-milestones/
└── my-system-poam/
    └── plan-of-action-and-milestones.json
```

## Trestle Operations

### Import
```bash
trestle import -f poam.json -o my-system-poam
```

### Validate
```bash
trestle validate -t plan-of-action-and-milestones -n my-system-poam
```

### Split and Merge
```bash
trestle split -t plan-of-action-and-milestones -n my-system-poam -e 'plan-of-action-and-milestones.poam-items'
trestle merge -t plan-of-action-and-milestones -n my-system-poam -e 'poam-items'
```

## Relationship to Other Models

```
Assessment Results → POA&M
       ↑                ↓
      SSP          Remediation Tracking
```

- A POA&M references an SSP with `import-ssp`.
- POA&M items usually come from Assessment Results findings.
- Make one POA&M item for each `not-satisfied` finding in Assessment Results.
- Milestones track remediation progress over time.

## Common Workflows

1. **Create from Assessment**: Extract findings from Assessment Results into POA&M items.
2. **Track Remediation**: Update risk status and add milestones as work progresses.
3. **Close Findings**: Mark risks as `closed` when they are remediated and verified.
4. **Report**: Make POA&M reports that show open items, progress, and timelines.

## Important: JSON-Based Workflow

The POA&M model does not have `trestle author` generate or assemble commands.
Catalogs, profiles, component definitions, and SSPs use those commands.
POA&M uses a **JSON-based workflow**:

```
create → split → edit JSON → merge → validate
```

Edit JSON directly with the split and merge cycle. That is the correct approach for POA&M.

## Additional Resources

- For worked examples and step-by-step walkthroughs, see [examples.md](examples.md)
