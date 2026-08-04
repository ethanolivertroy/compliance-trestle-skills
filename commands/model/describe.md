---
description: Describe the structure and contents of an OSCAL model
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<file> [element_path]"
---

Show the structure of an OSCAL model file.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `file` (`-f`): path to the model file
   - `element_path` (`-e`): optional element path for a deeper view

3. Run the describe command:
   ```
   trestle describe -f <file> [-e '<element_path>']
   ```

4. The output shows:
   - Model type and class name
   - For each field: name, type, and value preview
   - For lists: number of items and item type
   - For strings: value up to 100 characters
   - For split files: type shows as `stripped.<Type>`

5. Show the output in a readable format.

6. Suggest follow-up actions:
   - Look deeper with element paths such as `catalog.groups.0.controls.3`
   - Split large elements for editing
   - Note: wildcards (*) and commas are not supported in describe element paths
