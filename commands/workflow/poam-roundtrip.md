---
description: Full POA&M workflow: create from assessment findings, track remediation, manage milestones
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "<name> [--from-assessment <assessment_results_name>] [--from-ssp <ssp_name>]"
---

Run the full Plan of Action and Milestones (POA&M) workflow.
Use the JSON-based create, split, edit, merge, and validate cycle.

**Note**: POA&M does not have `trestle author` generate or assemble commands.
This workflow uses `trestle create`, `trestle split`, direct JSON editing, `trestle merge`, and `trestle validate`.

## Steps

1. **Check workspace**: confirm you are in a trestle workspace (`.trestle/` directory exists).

2. **Read $ARGUMENTS** for:
   - `name`: name for the POA&M (required, or ask the user)
   - Optional `--from-assessment <assessment_results_name>`: assessment results to extract findings from
   - Optional `--from-ssp <ssp_name>`: SSP to reference in the POA&M

3. **Pre-check references**:
   - If `--from-assessment` is provided, check that assessment results exist in `assessment-results/`
   - If `--from-ssp` is provided, check that the SSP exists in `system-security-plans/`
   - List available assessment results and SSPs for the user to choose from

4. **Extract findings from assessment results** (if `--from-assessment` is provided):
   - Read the assessment results JSON.
   - Find all findings with `target.status.state` = `not-satisfied`.
   - Show a summary table:
     ```
     | Control | Finding Title | Risk Level | Observations |
     |---------|--------------|------------|--------------|
     | AC-1    | Outdated...  | High       | 1            |
     | SC-7    | Missing...   | Moderate   | 2            |
     ```
   - Ask the user to confirm which findings should become POA&M items.

5. **Create the POA&M**:
   ```
   trestle create -t plan-of-action-and-milestones -o <name>
   ```

6. **Split for editing**:
   ```
   cd plan-of-action-and-milestones/<name>
   trestle split -f plan-of-action-and-milestones.json -e 'plan-of-action-and-milestones.import-ssp,plan-of-action-and-milestones.poam-items,plan-of-action-and-milestones.observations,plan-of-action-and-milestones.risks'
   ```

7. **Help create the POA&M** for each split file:

   - **import-ssp**: set the SSP href (use the `--from-ssp` value if provided)

   - **observations**: copy relevant observations from assessment results.
     Keep the UUIDs so cross-references stay valid.
     Each observation should have:
     - `methods`: EXAMINE, INTERVIEW, or TEST
     - `types`: finding, historic, or other types
     - `collected`: date the evidence was collected

   - **risks**: for each finding, create risk entries with:
     - `status`: initial status (often `open`)
     - `characterizations`: likelihood and impact ratings
     - `remediations`: planned actions with lifecycle (`recommendation` to `planned` to `completed`)
     - `tasks`: milestones with timing (start and end date ranges)

   - **poam-items**: create POA&M items that link to observations and risks:
     - `related-observations`: UUID references to observation entries
     - `related-risks`: UUID references to risk entries
     - `origins`: who identified the finding

   If `--from-assessment` was used, fill these sections from the extracted findings data.

   Show concrete JSON snippets for each section. See the `trestle-poam` skill for complete examples.

8. **Merge**:
   ```
   trestle merge -e 'plan-of-action-and-milestones.import-ssp,plan-of-action-and-milestones.poam-items,plan-of-action-and-milestones.observations,plan-of-action-and-milestones.risks'
   ```

9. **Validate**:
   ```
   trestle validate -t plan-of-action-and-milestones -n <name>
   ```

10. **Summary with risk breakdown and timeline**:
    - Total POA&M items created
    - Risk breakdown: items by risk level (high, moderate, low)
    - Status summary: open, investigating, remediating, deviation, closed
    - Milestone timeline: upcoming milestone dates
    - Recommend the `poam-manager` agent for ongoing remediation tracking
    - Remind the user to use Jinja templates for POA&M status reports (see the `trestle-jinja-templating` skill)
