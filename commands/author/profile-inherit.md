---
description: Generate an inheritance view from a profile and leveraged SSP
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<profile_name> --leveraged-ssp <ssp_name> <output_dir>"
---

Generate an inheritance view.
Filter a parent profile by inherited controls from a leveraged SSP.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `profile_name` (`--name`): parent profile name
   - `ssp_name` (`--leveraged-ssp`): name of the leveraged SSP
   - `output_dir` (`--output`): output directory

3. Run:
   ```
   trestle author profile-inherit --name <profile_name> --leveraged-ssp <ssp_name> --output <output_dir>
   ```

4. This filters the profile controls by what is inherited from the leveraged SSP.

5. Tell the user the inheritance concept:
   - Provider systems expose inherited controls in their SSP.
   - Consumer systems inherit those controls from the provider SSP.
   - This command shows which controls are inherited.
   - It also shows which controls need local implementation.
