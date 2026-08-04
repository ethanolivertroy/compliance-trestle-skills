---
description: Full assessment workflow: create or import, split, edit, merge, and validate assessment plans and results
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "[assessment-plan|assessment-results] [<name>] [--from-ssp <ssp_name>]"
---

Run the full assessment-plan or assessment-results authoring workflow.
Use the JSON-based create, split, edit, merge, and validate cycle.

**Note**: assessment models do not have `trestle author` generate or assemble commands.
This workflow uses `trestle create`, `trestle split`, direct JSON editing, `trestle merge`, and `trestle validate`.

## Steps

1. **Check workspace**: confirm you are in a trestle workspace (`.trestle/` directory exists).

2. **Read $ARGUMENTS** for:
   - `model_type`: either `assessment-plan` or `assessment-results` (default: ask the user)
   - `name`: name for the model (default: ask the user)
   - Optional `--from-ssp <ssp_name>`: SSP to reference in the assessment

3. **Pre-check references**:
   - If `--from-ssp` is provided, check that the SSP exists in `system-security-plans/`
   - If you create assessment-results, check for existing assessment-plans to reference
   - List available SSPs and assessment plans for the user to choose from

4. **Detect or confirm model type**:
   - If the type is not specified, ask: "Are you creating an assessment-plan or assessment-results?"
   - For assessment-results, check if an assessment-plan exists to reference with `import-ap`

5. **Create or import**:
   - For new models:
     ```
     trestle create -t <model_type> -o <name>
     ```
   - Note: `trestle create` generates placeholder `REPLACE_ME` values. Fill them in.

6. **Split with the matching element paths**:

   For **assessment-plan**:
   ```
   cd assessment-plans/<name>
   trestle split -f assessment-plan.json -e 'assessment-plan.import-ssp,assessment-plan.reviewed-controls,assessment-plan.assessment-subjects,assessment-plan.assessment-assets,assessment-plan.tasks,assessment-plan.local-definitions'
   ```

   For **assessment-results**:
   ```
   cd assessment-results/<name>
   trestle split -f assessment-results.json -e 'assessment-results.import-ap,assessment-results.results'
   ```

7. **Help edit each section** with JSON examples:

   For **assessment-plan**, help with each split file:
   - `import-ssp`: set the SSP href (use the `--from-ssp` value if provided)
   - `reviewed-controls`: define which controls are in scope for assessment
   - `assessment-subjects`: define what systems or components are being assessed
   - `local-definitions`: define activities with methods (EXAMINE, INTERVIEW, TEST)
   - `assessment-assets`: document tools and assessment platforms
   - `tasks`: schedule assessment activities with timing

   For **assessment-results**, help with each split file:
   - `import-ap`: set the assessment plan href
   - `results`: build result sets that contain:
     - `reviewed-controls`: controls that were assessed
     - `observations`: evidence collected (with methods, types, collected dates)
     - `risks`: identified risks (with characterizations: likelihood, impact)
     - `findings`: per-control findings with target status (`satisfied` / `not-satisfied`)
     - Link findings to observations and risks with UUIDs

   Show concrete JSON snippets for each section. See the `trestle-assessment` skill for complete examples.

8. **Merge**:

   For **assessment-plan**:
   ```
   trestle merge -e 'assessment-plan.import-ssp,assessment-plan.reviewed-controls,assessment-plan.assessment-subjects,assessment-plan.assessment-assets,assessment-plan.tasks,assessment-plan.local-definitions'
   ```

   For **assessment-results**:
   ```
   trestle merge -e 'assessment-results.import-ap,assessment-results.results'
   ```

9. **Validate**:
   ```
   trestle validate -t <model_type> -n <name>
   ```

10. **Summary and next steps**:
    - Report what was created or edited.
    - For assessment-plan: suggest creating assessment-results next.
    - For assessment-results: show a findings summary (satisfied vs. not-satisfied counts).
    - For assessment-results with `not-satisfied` findings: suggest creating a POA&M with `/compliance-trestle:workflow-poam-roundtrip`.
    - Remind the user about the `assessment-reviewer` agent for reviewing assessment documentation.
