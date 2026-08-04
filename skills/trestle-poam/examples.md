# POA&M: Worked Examples

These walkthroughs show how to make and manage POA&M documents.
Use the split and merge JSON workflow.
For core reference material, see [SKILL.md](SKILL.md).

## Step-by-Step: Creating POA&M from Assessment Findings

### 1. Identify Not-Satisfied Findings

Review assessment results for `not-satisfied` findings:

```bash
# Find all not-satisfied findings
grep -r '"state": "not-satisfied"' assessment-results/ --include="*.json" -B5
```

### 2. Create the POA&M

```bash
trestle create -t plan-of-action-and-milestones -o my-system-poam
```

### 3. Split for Editing

```bash
cd plan-of-action-and-milestones/my-system-poam

trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.import-ssp,plan-of-action-and-milestones.poam-items,plan-of-action-and-milestones.observations,plan-of-action-and-milestones.risks'
```

### 4. Edit import-ssp

Reference the system SSP:
```json
{
  "href": "../../system-security-plans/my-ssp/system-security-plan.json"
}
```

### 5. Copy Observations from Assessment Results

Copy relevant observations from your assessment results.
Keep the UUIDs. Other records use them as references:
```json
[
  {
    "uuid": "55555555-0000-4000-8000-000000000001",
    "title": "AC-1 Policy Review",
    "description": "Access control policy was last updated 3 years ago and does not reflect current procedures",
    "methods": ["EXAMINE"],
    "types": ["finding"],
    "collected": "2024-02-10T00:00:00Z"
  }
]
```

### 6. Create Risk Entries with Remediations

For each finding, create a risk entry with a remediation plan and milestones:
```json
[
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
    ],
    "remediations": [
      {
        "uuid": "88888888-0000-4000-8000-000000000001",
        "lifecycle": "planned",
        "title": "Update access control policy",
        "description": "Draft, review, and approve updated AC-1 policy",
        "tasks": [
          {
            "uuid": "99999999-0000-4000-8000-000000000001",
            "type": "milestone",
            "title": "Draft updated policy",
            "description": "Draft AC-1 policy incorporating current procedures",
            "timing": {
              "within-date-range": {
                "start": "2024-03-01",
                "end": "2024-03-15"
              }
            }
          },
          {
            "uuid": "99999999-0000-4000-8000-000000000002",
            "type": "milestone",
            "title": "Policy review and approval",
            "description": "Submit for management review and obtain approval",
            "timing": {
              "within-date-range": {
                "start": "2024-03-15",
                "end": "2024-03-31"
              }
            }
          }
        ]
      }
    ]
  }
]
```

### 7. Create POA&M Items

Link POA&M items to their observations and risks with UUIDs:
```json
[
  {
    "uuid": "aaaaaaaa-0000-4000-8000-000000000001",
    "title": "AC-1: Outdated Access Control Policy",
    "description": "Access control policy has not been reviewed or updated within the required timeframe",
    "related-observations": [
      { "observation-uuid": "55555555-0000-4000-8000-000000000001" }
    ],
    "related-risks": [
      { "risk-uuid": "66666666-0000-4000-8000-000000000001" }
    ],
    "origins": [
      {
        "actors": [{ "actor-uuid": "REPLACE_ME", "type": "party" }]
      }
    ],
    "remarks": "Identified during annual assessment. Target remediation: 30 days."
  }
]
```

### 8. Merge and Validate

```bash
trestle merge -e 'plan-of-action-and-milestones.import-ssp,plan-of-action-and-milestones.poam-items,plan-of-action-and-milestones.observations,plan-of-action-and-milestones.risks'
trestle validate -t plan-of-action-and-milestones -n my-system-poam
```

## Remediation Tracking Workflow

Track remediation progress.
Update the risk `status` field through the lifecycle:

### Status Transitions

```
open -> investigating -> remediating -> closed
  |
  +-> deviation-requested -> deviation-approved
```

### Update Status with Split and Merge

```bash
# Split just the risks for editing
trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.risks'

# Edit the risk status in the split file
# Then merge back
trestle merge -e 'plan-of-action-and-milestones.risks'
```

### Status Change: Open -> Investigating

```json
{
  "status": "investigating",
  "remediations": [
    {
      "lifecycle": "planned",
      "title": "Investigate scope of outdated policy",
      "description": "Determine which sections need updates and identify stakeholders"
    }
  ]
}
```

### Status Change: Investigating -> Remediating

```json
{
  "status": "remediating",
  "remediations": [
    {
      "lifecycle": "planned",
      "title": "Update access control policy",
      "description": "Draft, review, and approve updated policy",
      "tasks": [
        { "type": "milestone", "title": "Draft complete", "timing": { "within-date-range": { "start": "2024-03-01", "end": "2024-03-15" } } },
        { "type": "milestone", "title": "Review complete", "timing": { "within-date-range": { "start": "2024-03-15", "end": "2024-03-31" } } }
      ]
    }
  ]
}
```

### Status Change: Remediating -> Closed

```json
{
  "status": "closed",
  "remediations": [
    {
      "lifecycle": "completed",
      "title": "Updated access control policy approved",
      "description": "Policy v2.0 approved by CISO on 2024-03-28"
    }
  ]
}
```

### Status Change: Open -> Deviation (Risk Acceptance)

```json
{
  "status": "deviation-requested",
  "risk-log": {
    "entries": [
      {
        "uuid": "...",
        "title": "Risk acceptance requested",
        "description": "Legacy system cannot support updated controls. Compensating controls documented.",
        "start": "2024-03-01T00:00:00Z"
      }
    ]
  }
}
```

## Milestone Planning Examples

### Example 1: Policy Update (30-Day Remediation)

```json
{
  "uuid": "...",
  "lifecycle": "planned",
  "title": "Update AC-1 Policy",
  "description": "Review, update, and approve access control policy",
  "tasks": [
    {
      "uuid": "...", "type": "milestone",
      "title": "Gap analysis complete",
      "timing": { "within-date-range": { "start": "2024-03-01", "end": "2024-03-07" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "Draft policy updated",
      "timing": { "within-date-range": { "start": "2024-03-07", "end": "2024-03-21" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "Policy approved and published",
      "timing": { "within-date-range": { "start": "2024-03-21", "end": "2024-03-31" } }
    }
  ]
}
```

### Example 2: Technical Fix (90-Day Remediation)

```json
{
  "uuid": "...",
  "lifecycle": "planned",
  "title": "Implement MFA for SC-7 Boundary Access",
  "description": "Deploy multi-factor authentication for network boundary management interfaces",
  "tasks": [
    {
      "uuid": "...", "type": "milestone",
      "title": "MFA solution selected and approved",
      "timing": { "within-date-range": { "start": "2024-03-01", "end": "2024-03-15" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "MFA deployed to staging",
      "timing": { "within-date-range": { "start": "2024-03-15", "end": "2024-04-15" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "MFA deployed to production",
      "timing": { "within-date-range": { "start": "2024-04-15", "end": "2024-05-15" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "Validation testing complete",
      "timing": { "within-date-range": { "start": "2024-05-15", "end": "2024-05-30" } }
    }
  ]
}
```

### Example 3: Phased Approach (180-Day Remediation)

```json
{
  "uuid": "...",
  "lifecycle": "planned",
  "title": "Implement Comprehensive Audit Logging (AU-2)",
  "description": "Phase in centralized audit logging across all system components",
  "tasks": [
    {
      "uuid": "...", "type": "milestone",
      "title": "Phase 1: Core infrastructure logging",
      "timing": { "within-date-range": { "start": "2024-03-01", "end": "2024-04-30" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "Phase 2: Application-level logging",
      "timing": { "within-date-range": { "start": "2024-05-01", "end": "2024-06-30" } }
    },
    {
      "uuid": "...", "type": "milestone",
      "title": "Phase 3: Log correlation and alerting",
      "timing": { "within-date-range": { "start": "2024-07-01", "end": "2024-08-31" } }
    }
  ]
}
```

## Using Split and Merge for POA&M Editing

### Split Specific Elements

```bash
# Split only POA&M items for editing
trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.poam-items'

# Split only risks (for status updates)
trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.risks'

# Split observations
trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.observations'
```

### Merge Order

Merge in the same order as the split, or merge all at once:

```bash
# Merge individual elements
trestle merge -e 'plan-of-action-and-milestones.observations'
trestle merge -e 'plan-of-action-and-milestones.risks'
trestle merge -e 'plan-of-action-and-milestones.poam-items'

# Or merge all at once
trestle merge -e 'plan-of-action-and-milestones.observations,plan-of-action-and-milestones.risks,plan-of-action-and-milestones.poam-items'
```

### Edit-One-Field Pattern

To update one field, such as a risk status, use a targeted split, edit, and merge:

```bash
# 1. Split just risks
trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.risks'

# 2. Edit the specific risk's status field in the split file

# 3. Merge back
trestle merge -e 'plan-of-action-and-milestones.risks'

# 4. Validate
trestle validate -t plan-of-action-and-milestones -n my-system-poam
```
