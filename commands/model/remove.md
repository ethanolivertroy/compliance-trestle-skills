---
description: Remove a subcomponent from an OSCAL model
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<file> <element_path>"
---

Remove a subcomponent (element) from an OSCAL model file.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `file` (`-f`): the JSON or YAML file to change
   - `element_path` (`-e`): the element path to remove

3. Tell the user the element path syntax:
   - Use dot notation: `catalog.metadata`, `catalog.back-matter`
   - The command removes the specified element and its children from the parent model.
   - The command does not remove one item from a list. It removes the full list or dict.
   - Wildcard element paths are not supported.

4. Show the element state before removal:
   ```
   trestle describe -f <file> -e <element_path>
   ```

5. Run the remove command:
   ```
   trestle remove -f <file> -e <element_path>
   ```

6. Confirm the element was removed. Show the updated model structure.

7. Note: this is the inverse of `trestle add`. The file is changed in place.
