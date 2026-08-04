---
description: Generate SSP markdown from a profile and optional component definitions
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<profile_name> [--compdefs comp1,comp2] <output_dir>"
---

Generate System Security Plan (SSP) markdown from a profile and optional component definitions.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `profile_name` (`--profile`): profile that defines the control baseline
   - `output_dir` (`--output`): markdown output directory
   - Optional: `--compdefs`: comma-separated list of component-definition names
   - Optional: `--yaml`, `--overwrite-header-values`, `--force-overwrite`
   - Optional: `--include-all-parts`: include all parts (default: only parts with rules)

3. Make sure the profile imports resolve correctly. Use `trestle href` if needed.

4. Check that the profile file is writable.
   Some import paths make `profile.json` read-only.
   Then `ssp-generate` fails with errors such as `sed: permission denied`.
   Fix with:
   ```
   chmod u+w profiles/<profile_name>/profile.json
   ```

5. Run:
   ```
   trestle author ssp-generate --profile <profile_name> --output <output_dir> [--compdefs <comp1,comp2>]
   ```

   Note: for a fresh baseline such as NIST 800-53 High, expect many parameter and ODP warnings.
   The warnings say values are not set.
   These warnings are expected for an unpopulated template.
   They are resolved when `ssp-values` are filled in.
   They do not mean the command failed.

6. Show the generated structure:
   - One markdown file per control
   - Each control has sections per statement part
   - Each part has response sections per component
   - The "This System" component is always present
   - Named components come from component definitions
   - If `--compdefs` is not provided, only "This System" sections appear

7. Tell the user the markdown structure:
   - YAML header: parameters, rules, rule parameters
   - Control statement (read-only)
   - Implementation sections per part per component
   - `#### Implementation Status:` per component
   - `#### Rules:` (read-only, from component definitions)

8. Tell the user what to edit:
   - Replace `<!-- Add control implementation description here -->` comments with prose
   - Set `ssp-values:` for parameters
   - Set implementation status values
   - Add implementation prose for each component per statement part

9. Next steps: edit all control responses, then run `ssp-assemble`.
   Use the author command `trestle author ssp-assemble`.
   Do not use the generic `trestle assemble`.
