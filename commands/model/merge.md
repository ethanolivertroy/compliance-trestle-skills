---
description: Merge split OSCAL sub-components back into their parent file
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<element_path>"
---

Merge split OSCAL sub-component files back into their parent file.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `element_path` (`-e`): the element path to merge (must have at least 2 elements)
   - Use `.*` to merge all sub-components: `catalog.*`

3. Go to the correct directory. Merge is relative to the working directory.

4. Run the merge command:
   ```
   trestle merge -e '<element_path>'
   ```

5. The command first merges any split sub-components. Then it merges the target.

6. Show the file structure after the merge.

7. Note: the merge command is the reverse of split.
   It combines files from subdirectories back into the parent JSON or YAML file.
