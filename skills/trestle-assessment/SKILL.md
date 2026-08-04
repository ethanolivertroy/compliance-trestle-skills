---
name: trestle-assessment
description: >-
  Use this skill for OSCAL assessment plans and assessment results models in Compliance Trestle.
  Use it for assessment plans, assessment results, security assessments, SAP, SAR,
  assessment activities, findings, observations, or assessment-related OSCAL models.
allowed-tools: Bash, Read, Glob, Grep, Write, Edit
---

# OSCAL Assessment Models in Trestle

## Overview

OSCAL defines two assessment models:
- **Assessment Plan (SAP)**: This model defines the scope, method, and schedule for a security assessment.
- **Assessment Results (SAR)**: This model records findings, observations, and risks from an assessment.

## Assessment Plan (SAP)

### Purpose
The plan defines what you assess, how you assess it, when you assess it, and who assesses it.
The model matches a Security Assessment Plan in FedRAMP and NIST terms.

### Key Components

```json
{
  "assessment-plan": {
    "uuid": "...",
    "metadata": { "title": "...", "version": "..." },
    "import-ssp": { "href": "#..." },
    "local-definitions": {
      "activities": [],
      "objectives-and-methods": []
    },
    "reviewed-controls": {
      "control-selections": [
        { "include-controls": [{ "control-id": "ac-1" }] }
      ]
    },
    "assessment-subjects": [],
    "assessment-assets": {
      "assessment-platforms": []
    },
    "tasks": []
  }
}
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `import-ssp` | References the SSP under assessment |
| `reviewed-controls` | Controls in scope for this assessment |
| `assessment-subjects` | Systems, components, or inventories under assessment |
| `assessment-assets` | Tools and platforms used for assessment |
| `tasks` | Scheduled assessment activities |
| `local-definitions.activities` | Assessment activities and their steps |
| `local-definitions.objectives-and-methods` | Assessment objectives tied to controls |

### Workspace Location
```
assessment-plans/
└── my-assessment/
    └── assessment-plan.json
```

## Assessment Results (SAR)

### Purpose
The results record the outcomes of a security assessment.
Outcomes include findings, observations, and risk determinations.

### Key Components

```json
{
  "assessment-results": {
    "uuid": "...",
    "metadata": { "title": "...", "version": "..." },
    "import-ap": { "href": "#..." },
    "results": [
      {
        "uuid": "...",
        "title": "Assessment Round 1",
        "start": "2024-01-15T00:00:00Z",
        "end": "2024-01-30T00:00:00Z",
        "reviewed-controls": {},
        "findings": [],
        "observations": [],
        "risks": []
      }
    ]
  }
}
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `import-ap` | References the assessment plan |
| `results` | One or more assessment result sets |
| `results[].findings` | Individual assessment findings per control |
| `results[].observations` | Evidence and observations collected |
| `results[].risks` | Identified risks with severity |
| `results[].attestations` | Assessor attestation statements |

### Finding Structure
```json
{
  "uuid": "...",
  "title": "AC-1 Finding",
  "description": "...",
  "target": {
    "type": "objective-id",
    "target-id": "ac-1",
    "status": { "state": "not-satisfied" }
  },
  "related-observations": [{ "observation-uuid": "..." }],
  "related-risks": [{ "risk-uuid": "..." }]
}
```

### Finding States
| State | Meaning |
|-------|---------|
| `satisfied` | Control objective is met |
| `not-satisfied` | The control objective is not met. Make a POA&M entry |

### Workspace Location
```
assessment-results/
└── my-assessment-results/
    └── assessment-results.json
```

## Trestle Operations

### Import Assessment Models
```bash
trestle import -f assessment-plan.json -o my-assessment
trestle import -f assessment-results.json -o my-results
```

### Validate
```bash
trestle validate -t assessment-plan -n my-assessment
trestle validate -t assessment-results -n my-results
```

### Split and Merge
Assessment models support split and merge.
Other OSCAL models also support split and merge:
```bash
trestle split -t assessment-results -n my-results -e 'assessment-results.results'
trestle merge -t assessment-results -n my-results -e 'results'
```

## Relationship to Other Models

```
Catalog → Profile → SSP → Assessment Plan → Assessment Results → POA&M
```

- An Assessment Plan references an SSP with `import-ssp`.
- Assessment Results reference an Assessment Plan with `import-ap`.
- Findings in Assessment Results feed into POA&M items.
- Controls assessed are selected from the SSP profile.

## Important: JSON-Based Workflow

Assessment models do not have `trestle author` generate or assemble commands.
Catalogs, profiles, component definitions, and SSPs use those commands.
Assessment plans and assessment results use a **JSON-based workflow**:

```
create → split → edit JSON → merge → validate
```

Edit JSON directly with the split and merge cycle. That is the correct approach for these models.

## Additional Resources

- For worked examples and step-by-step walkthroughs, see [examples.md](examples.md)
