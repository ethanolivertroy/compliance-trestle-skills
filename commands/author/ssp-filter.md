---
description: Filter an SSP by profile or components
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<ssp_name> [--profile <profile> | --components <comp1,comp2>] <output_ssp>"
---

Filter a System Security Plan to include only specific controls or components.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `ssp_name` (`--name`): SSP to filter
   - Filter mode (one of):
     - `--profile <profile>`: keep only controls in this profile
     - `--components <comp1,comp2>`: keep only these components
     - `--exclude-components <comp1,comp2>`: exclude these components
   - `output_ssp` (`--output`): name for the filtered SSP

3. Run the matching filter command:
   ```
   trestle author ssp-filter --name <ssp_name> --profile <profile> --output <output_ssp>
   ```
   or:
   ```
   trestle author ssp-filter --name <ssp_name> --components <comp1,comp2> --output <output_ssp>
   ```

4. Tell the user these use cases:
   - Filter by profile: make an SSP subset for a specific compliance framework.
   - Filter by components: make an SSP view for specific system components.
   - Exclude components: remove proprietary content before external distribution.

5. Show the output. Confirm what was filtered.
