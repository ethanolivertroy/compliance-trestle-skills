# Assessment Models: Worked Examples

These walkthroughs show how to make assessment plans and assessment results.
Use the split and merge JSON workflow.
For core reference material, see [SKILL.md](SKILL.md).

## Step-by-Step: Creating an Assessment Plan

### 1. Create the Assessment Plan

```bash
trestle create -t assessment-plan -o my-assessment
```

This command creates `assessment-plans/my-assessment/assessment-plan.json`.
Placeholder fields are marked `REPLACE_ME`.

### 2. Split for Editing

Split the model into smaller pieces:

```bash
cd assessment-plans/my-assessment

# Split top-level sections
trestle split -f assessment-plan.json -e 'assessment-plan.import-ssp,assessment-plan.reviewed-controls,assessment-plan.assessment-subjects,assessment-plan.assessment-assets,assessment-plan.tasks,assessment-plan.local-definitions'
```

This command creates one JSON file for each section in the model directory.

### 3. Edit Each Section

**import-ssp**: Reference the SSP under assessment:
```json
{
  "href": "../../system-security-plans/my-ssp/system-security-plan.json"
}
```

**reviewed-controls**: Define which controls are in scope:
```json
{
  "control-selections": [
    {
      "description": "All AC and SC family controls",
      "include-controls": [
        { "control-id": "ac-1" },
        { "control-id": "ac-2" },
        { "control-id": "ac-3" },
        { "control-id": "sc-7" },
        { "control-id": "sc-8" }
      ]
    }
  ]
}
```

**assessment-subjects**: Define what you assess:
```json
[
  {
    "type": "component",
    "description": "All system components in the authorization boundary",
    "include-all": {}
  }
]
```

**local-definitions.activities**: Define assessment activities:
```json
[
  {
    "uuid": "11111111-0000-4000-8000-000000000001",
    "title": "Document Review",
    "description": "Review access control policies and procedures",
    "props": [
      { "name": "method", "value": "EXAMINE" }
    ],
    "steps": [
      {
        "uuid": "11111111-0000-4000-8000-000000000010",
        "title": "Review AC policy document",
        "description": "Verify AC policy is current and approved"
      }
    ],
    "related-controls": {
      "control-selections": [
        { "include-controls": [{ "control-id": "ac-1" }] }
      ]
    }
  }
]
```

**assessment-assets**: Document tools and platforms:
```json
{
  "assessment-platforms": [
    {
      "uuid": "22222222-0000-4000-8000-000000000001",
      "title": "Nessus Vulnerability Scanner",
      "props": [
        { "name": "type", "value": "tool" }
      ]
    }
  ]
}
```

**tasks**: Schedule assessment activities:
```json
[
  {
    "uuid": "33333333-0000-4000-8000-000000000001",
    "type": "action",
    "title": "Phase 1: Document Review",
    "description": "Review policies and procedures",
    "timing": {
      "within-date-range": {
        "start": "2024-02-01T00:00:00Z",
        "end": "2024-02-15T00:00:00Z"
      }
    },
    "associated-activities": [
      {
        "activity-uuid": "11111111-0000-4000-8000-000000000001",
        "subjects": [
          {
            "type": "component",
            "include-all": {}
          }
        ]
      }
    ]
  }
]
```

### 4. Merge Back

```bash
trestle merge -e 'assessment-plan.import-ssp,assessment-plan.reviewed-controls,assessment-plan.assessment-subjects,assessment-plan.assessment-assets,assessment-plan.tasks,assessment-plan.local-definitions'
```

### 5. Validate

```bash
trestle validate -t assessment-plan -n my-assessment
```

## Step-by-Step: Building Assessment Results

### 1. Create Assessment Results

```bash
trestle create -t assessment-results -o my-results
```

### 2. Split for Editing

```bash
cd assessment-results/my-results

trestle split -f assessment-results.json -e 'assessment-results.import-ap,assessment-results.results'
```

### 3. Edit Each Section

**import-ap**: Reference the assessment plan:
```json
{
  "href": "../../assessment-plans/my-assessment/assessment-plan.json"
}
```

**results**: Build result sets with findings, observations, and risks:
```json
[
  {
    "uuid": "44444444-0000-4000-8000-000000000001",
    "title": "Annual Assessment 2024",
    "description": "Annual security assessment results",
    "start": "2024-02-01T00:00:00Z",
    "end": "2024-02-28T00:00:00Z",
    "reviewed-controls": {
      "control-selections": [
        {
          "include-controls": [
            { "control-id": "ac-1" },
            { "control-id": "ac-2" },
            { "control-id": "sc-7" }
          ]
        }
      ]
    },
    "observations": [
      {
        "uuid": "55555555-0000-4000-8000-000000000001",
        "title": "AC-1 Policy Review",
        "description": "Access control policy was last updated 3 years ago and does not reflect current procedures",
        "methods": ["EXAMINE"],
        "types": ["finding"],
        "collected": "2024-02-10T00:00:00Z",
        "subjects": [
          { "subject-uuid": "REPLACE_ME", "type": "component" }
        ]
      },
      {
        "uuid": "55555555-0000-4000-8000-000000000002",
        "title": "SC-7 Boundary Scan",
        "description": "Network boundary protection verified via automated scanning",
        "methods": ["TEST"],
        "types": ["finding"],
        "collected": "2024-02-12T00:00:00Z"
      }
    ],
    "risks": [
      {
        "uuid": "66666666-0000-4000-8000-000000000001",
        "title": "Outdated Access Control Policy",
        "description": "AC policy has not been updated in 3 years",
        "statement": "Without current policy, access controls may not meet organizational requirements",
        "status": "open",
        "characterizations": [
          {
            "origin": {
              "actors": [{ "actor-uuid": "REPLACE_ME", "type": "party" }]
            },
            "facets": [
              { "name": "likelihood", "value": "moderate", "system": "https://fedramp.gov" },
              { "name": "impact", "value": "high", "system": "https://fedramp.gov" }
            ]
          }
        ]
      }
    ],
    "findings": [
      {
        "uuid": "77777777-0000-4000-8000-000000000001",
        "title": "AC-1 Finding",
        "description": "Access control policy is outdated",
        "target": {
          "type": "objective-id",
          "target-id": "ac-1",
          "status": { "state": "not-satisfied" },
          "description": "Policy document has not been reviewed or updated within the required timeframe"
        },
        "related-observations": [
          { "observation-uuid": "55555555-0000-4000-8000-000000000001" }
        ],
        "related-risks": [
          { "risk-uuid": "66666666-0000-4000-8000-000000000001" }
        ]
      },
      {
        "uuid": "77777777-0000-4000-8000-000000000002",
        "title": "AC-2 Finding",
        "description": "Account management procedures verified",
        "target": {
          "type": "objective-id",
          "target-id": "ac-2",
          "status": { "state": "satisfied" }
        }
      },
      {
        "uuid": "77777777-0000-4000-8000-000000000003",
        "title": "SC-7 Finding",
        "description": "Boundary protection controls verified",
        "target": {
          "type": "objective-id",
          "target-id": "sc-7",
          "status": { "state": "satisfied" }
        },
        "related-observations": [
          { "observation-uuid": "55555555-0000-4000-8000-000000000002" }
        ]
      }
    ]
  }
]
```

### 4. Merge and Validate

```bash
trestle merge -e 'assessment-results.import-ap,assessment-results.results'
trestle validate -t assessment-results -n my-results
```

## Linking Findings to SSP Controls

Assessment findings trace back to SSP controls through the `target` field:

| Finding Field | Maps To |
|---------------|---------|
| `target.target-id` | Control ID from SSP. Examples: `ac-1`, `sc-7` |
| `target.type` | Usually `objective-id` for control-level findings |
| `target.status.state` | `satisfied` or `not-satisfied` |
| `related-observations[].observation-uuid` | UUID of observation providing evidence |
| `related-risks[].risk-uuid` | UUID of associated risk entry |

### Traceability Pattern

```
SSP Control (ac-1) <- target.target-id
    |
Finding (uuid: 77777...) <- documents the assessment result
    |
Observation (uuid: 55555...) <- provides evidence (with related-observations)
    |
Risk (uuid: 66666...) <- characterizes the risk (with related-risks)
    |
POA&M Item <- tracks remediation (cross-referenced by observation/risk UUIDs)
```

Each UUID builds a traceable chain.
The chain starts at the control requirement.
It continues through evidence collection.
It ends at risk management.

## Integration with Task System

Trestle tasks can convert external assessment data into OSCAL assessment results:

- **XCCDF -> Assessment Results**: Convert SCAP/XCCDF scan results using `xccdf-result-to-oscal-ar`
- **Tanium -> Assessment Results**: Convert Tanium compliance data using `tanium-to-oscal-ar`

### Example: XCCDF to Assessment Results

```ini
# In trestle config.ini
[task.xccdf-to-ar]
type = xccdf-result-to-oscal-ar
input-dir = xccdf-results/
output-dir = assessment-results/
```

```bash
trestle task xccdf-to-ar -c config.ini
```

See the `trestle-task-system` skill for full task configuration details.
