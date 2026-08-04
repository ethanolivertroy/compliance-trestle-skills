# Personas and Architecture Reference

This file is detailed reference material for the end-to-end compliance pipeline.
Load this file when you need more context than the SKILL.md overview.

## Full Persona Table

The enterprise-wide compliance process involves these personas and their actions:

| # | Persona | Role | Artifacts Produced | Artifacts Consumed | Trestle Interface |
|---|---------|------|-------------------|-------------------|-------------------|
| 1 | Regulators | Define regulations, laws, standards | Catalogs (controls + parameters), Profiles (baselines) | None (source of truth) | `catalog-generate/assemble` |
| 2 | Compliance Officers / CISO | Interpret regulations, customize guidance | Profiles (tailored baselines with org-specific guidance) | Catalogs | `profile-generate/assemble`, `xlsx-to-oscal-profile` |
| 3 | Security Engineers | Define cross-product rules for enterprise environments | Component Definitions (enterprise rules) | Profiles, Catalogs | `csv-to-oscal-cd`, `component-generate/assemble` |
| 4 | Control Providers (vendors) | Implement controls in products. Map controls to rules | Component Definitions (Service type) | Profiles, Catalogs | `csv-to-oscal-cd`, `component-generate/assemble` |
| 5 | Control Assessors (PVP vendors) | Implement checks to test rules. Map rules to checks | Component Definitions (Validation type) | Component Definitions (Service), Profiles | `csv-to-oscal-cd` (with `Check_Id`) |
| 6 | System Owners / CIO | Procurement, integration, compliance of platforms | System Security Plans | Profiles, Component Definitions | `ssp-generate/assemble/filter` |
| 7 | CISO (link to auditors) | Prepare ATO package (SSP + SAR) | SSP, Assessment Plans | Profiles, Component Definitions, Assessment Results | `ssp-generate/assemble` |
| 8 | Assessors | Test applicable rules, generate assessment results | Assessment Results (SAR) | Assessment Plans, Component Definitions | `xccdf-result-to-oscal-ar`, `tanium-result-to-oscal-ar` |
| 9 | System Owners (remediation) | Corrective actions based on SAR failures | POA&M (plans of action) | Assessment Results | `create`, `split`, `merge` (JSON workflow) |
| 10 | Operations / Developers | Day-to-day remediation of failing controls | Remediated systems | POA&M, Assessment Results | N/A (consume trestle artifacts) |
| 11 | Audit Officials | Retrieve SSP + SAR in audit template format | Audit reports | SSP, Assessment Results | Trestle export utilities (HTML, XLSX, PDF) |

**Key insight from COMPASS Part 1**: In real organizations, one person can cover more than one persona role.
Separation of duties is logical. It is not always physical.
Trestle Git workflow is artifact-centric.
One person can author in more than one repo when that person has the right access.

## CPAC Exchange Protocol (EP1-EP4)

The Compliance Policy Administration Center (CPAC) orchestrates PVPs.
It uses a four-step Exchange Protocol.
The protocol uses OSCAL artifacts:

### EP1: Policy Artifacts Registration
- Compliance personas register OSCAL artifacts with the CPAC. Artifacts include catalogs, profiles, component definitions, and assessment plans.
- These artifacts are authored with the Trestle agile authoring workflow. They are stored in Git.

### EP2: Assessment Plan Distribution
- CPAC distributes assessment plans and policy configurations to PVPs/PEPs.
- For Kubernetes: OCM PolicyGenerator composes policies from component definitions.
- For Auditree: C2P generates `auditree.json` configuration from component definitions.

### EP3: Compliance Scan Result Retrieval
- PVPs execute checks against target systems.
- Results are collected in PVP-native format.
- CPAC (with C2P) normalizes results to OSCAL Assessment Results format.

### EP4: Enterprise Posture Registration
- Aggregated posture is registered with GRC centers or audit agencies.
- OSCAL Assessment Results support cross-PVP posture aggregation.
- Supports Authorization to Operate (ATO) workflows.

## CPAC Topologies

### Topology 1: Declarative Policies (Kubernetes)

For Kubernetes environments using policy engines (GateKeeper/OPA, Kyverno, Kube-bench):

```
Trestle (Compliance-as-Code authoring)
    |
    v
CPAC (Open Cluster Management)
    |
    v  PolicyGenerator (CRDs)
Kubernetes Policy Engines (PVPs)
    |
    v  Policy Report CRDs
CPAC --> OSCAL Assessment Results
```

- **Policy format**: Declarative YAML manifests (CRDs)
- **Distribution**: OCM distributes policies to managed clusters
- **Results**: Kubernetes Policy Report CRD, normalized to OSCAL

### Topology 2: Imperative Policies (Auditree / Ansible)

For operational compliance that needs complex validation logic:

```
Trestle (Compliance-as-Code authoring)
    |
    v
CPAC (C2P with Auditree plugin)
    |
    v  auditree.json + fetchers/checks
Auditree Framework (PVP)
    |
    v  check_results.json
CPAC --> OSCAL Assessment Results
```

- **Policy format**: Python scripts (fetchers + checks)
- **Configuration**: `auditree.json` with parameters from component definitions
- **Results**: Proprietary `check_results.json`, normalized to OSCAL

### Topology 3: Heterogeneous Cloud (Standard Exchange Protocol)

For complex environments with multiple PVP types:

```
Trestle (Compliance-as-Code authoring)
    |
    v
CPAC Cloud Orchestrator (EP1-EP4)
    |
    +---> Kubernetes CPAC (declarative PVPs)
    +---> Auditree CPAC (imperative PVPs)
    +---> Custom PVP (with C2P plugin)
    |
    v  Aggregated OSCAL Assessment Results
GRC / Audit Center
```

- **Hierarchical**: Cloud CPAC orchestrates specialized CPACs with standard interfaces.
- **Extensible**: New PVP types are added with C2P plugins.
- **Aggregated**: All results are normalized to OSCAL for cross-PVP posture.

## C2P Plugin Interface

C2P plugins implement two core methods:

### `generate_pvp_policy`

Reads an OSCAL component definition and generates PVP-specific policy configuration:

- **Input**: OSCAL Component Definition (rules, parameters, check mappings)
- **Output**: PVP-native configuration
  - Auditree: `auditree.json` with parameter values substituted
  - Kubernetes/OCM: PolicyGenerator manifests with compliance metadata

### `generate_pvp_result`

Reads PVP-native results and produces OSCAL Assessment Results:

- **Input**: PVP-native output. Example: `check_results.json` for Auditree
- **Output**: OSCAL Assessment Results with:
  - Observations mapped to rules with `Check_Id`
  - Findings mapped to controls with component definition traceability
  - Overall control posture: satisfied / not-satisfied

## ComplianceDeployment CRD Example

For Kubernetes C2P deployments, the ComplianceDeployment custom resource defines the
compliance-to-policy binding:

```yaml
apiVersion: compliance-to-policy.io/v1alpha1
kind: ComplianceDeployment
metadata:
  name: nist-high
spec:
  compliance:
    name: NIST_SP-800-53-HIGH
    catalog:
      url: https://raw.githubusercontent.com/.../NIST_SP-800-53_rev5_catalog.json
    profile:
      url: https://raw.githubusercontent.com/.../NIST_SP-800-53_rev5_HIGH-baseline_profile.json
    componentDefinition:
      url: https://raw.githubusercontent.com/.../component-definition.json
  policyResources:
    url: https://github.com/.../policy-resources
  clusterGroups:
    - name: cluster-nist-high
      matchLabels:
        level: nist-high
  binding:
    compliance: NIST_SP-800-53-HIGH
    clusterGroups:
      - cluster-nist-high
```

This CRD binds:
- **Compliance artifacts** (catalog, profile, component definition) to
- **Policy resources** (Kubernetes policy manifests) applied to
- **Cluster groups** (selected by label)

## Auditree Project Structure

Auditree uses a structured Python project for imperative policy validation:

```
auditree-project/
  fetchers/           # Python scripts that collect evidence from target systems
    fetch_github.py   # Example: fetch GitHub org members with the API
  checks/             # Python scripts that validate evidence against desired state
    test_github.py    # Example: checks member count meets threshold
  controls.json       # Maps check module paths to accreditations
  auditree.json       # Global config: evidence locker URL, rule parameters
```

- **Fetchers**: Collect actual state (evidence) from target systems with APIs.
- **Checks**: Compare actual state against desired state (rules/parameters).
- **controls.json**: Lists all checks with their Python module paths and accreditations.
- **auditree.json**: Configuration with parameter values. C2P generates this from component definitions.

The `Check_Id` in the component definition CSV is the full Python module path
of the check method.
Example: `demo_examples.checks.test_github.GitHubOrgs.test_members_is_not_empty`.

## SC-7 Trust-Zone Validation Pattern

From COMPASS Part 5, a pattern for validation of network boundary protection (NIST SC-7)
uses four interdependent rules applied to VPC/subnet architecture:

| Rule | Name | What It Checks |
|------|------|----------------|
| R1 | Tagging | Each subnet must be labeled exactly one of: `trust-zone:edge` or `trust-zone:private` |
| R2 | PublicGateway | Public gateways may only be attached to subnets labeled `trust-zone:edge` |
| R3 | Taint | Cluster nodes in `trust-zone:edge` subnets must have taint `trust-zone=edge:NoSchedule` |
| R4 | Tolerance | Only edge-approved images may tolerate `trust-zone=edge:NoSchedule` |

**Key property**: All four rules must pass at the same time.
If all pass, the labeling is correct.
A subnet without internet access cannot be labeled `edge`.
Rule R2 would fail.

This pattern shows that complex controls can need more than one coordinated rule.
SC-7 boundary protection is an example.
One configuration check is not enough.
These rules are usually implemented as imperative checks in Rego or Python.
Map them to the control with a Validation component definition.
Set each `Check_Id` to the rule implementation.

## Pre-Deployment vs Post-Deployment Assessment

The COMPASS architecture uses **"write once, use many times"** for policy checks:

- **Pre-deployment (CI/CD)**: Assess compliance against deployment artifacts
  (Terraform plans, Helm charts, IaC templates) before deployment.
- **Post-deployment (runtime)**: Assess compliance against running systems
  (API payloads, pod configurations, live evidence) on a schedule.

Reuse the same check logic in both contexts.
Only the evidence source changes.
An evidence abstraction layer lets the same check read pre-deployment artifacts or runtime evidence.
You do not change the validation logic.
