---
description: Full SSP authoring workflow - generate, edit, and assemble
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "<profile_name> [--compdefs comp1,comp2]"
---

Run the full System Security Plan authoring roundtrip workflow.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `profile_name`: the profile that defines the control baseline
   - Optional `--compdefs`: comma-separated component definition names

3. **Pre-check**:
   - Check that the profile exists and that its imports resolve.
   - Check that the profile file is writable.
     Some import paths make `profile.json` read-only.
     Then `ssp-generate` fails with `sed: permission denied`.
     Fix with `chmod u+w profiles/<profile_name>/profile.json`.
   - If compdefs are specified, check that they exist in `component-definitions/`.
   - List the controls that will be included.

4. **Generate phase**:
   ```
   trestle author ssp-generate --profile <profile_name> --output ssp-markdown [--compdefs <comps>]
   ```
   Warn the user that a fresh baseline produces many parameter and ODP warnings for unset values.
   These warnings are expected for an unpopulated template. They are not errors.

5. Show the structure. Tell the user:
   - One file per control with implementation sections
   - "This System" component for overall system responses
   - Named components from component definitions (if provided)
   - Without compdefs, only "This System" sections appear
   - Each statement part needs a response per component
   - Implementation status must be set per component

6. **Edit phase**: help the user write implementation responses:
   - Show a sample control markdown.
   - Tell the user about the `<!-- Add control implementation description here -->` placeholders.
   - Tell the user the implementation status options: implemented, partial, planned, alternative, not-applicable.
   - Tell the user how parameter handling works (`ssp-values`).
   - Help the user write responses for key controls if requested.

7. **Assemble phase**:
   ```
   trestle author ssp-assemble --markdown ssp-markdown --output my-ssp
   ```

8. Validate and provide a summary:
   - Number of controls addressed
   - Implementation status breakdown
   - Any controls with missing responses
