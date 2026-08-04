---
description: Split an OSCAL model into smaller sub-component files
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<file> <element_path>"
---

Split an OSCAL model file into smaller sub-component files to make editing easier.

## Steps

1. Check that you are in a trestle workspace. Go to the model directory.

2. Read $ARGUMENTS for:
   - `file` (`-f`): the JSON or YAML file to split
   - `element_path` (`-e`): the element path or paths to split out (comma-separated)

3. Tell the user the element path syntax:
   - Use dot notation: `catalog.metadata`, `catalog.groups`
   - Use a `.*` suffix to split array items into individual files: `catalog.groups.*`
   - Without `.*`, arrays go into one file: `catalog.groups`
   - Quote paths that contain `*` on Unix shells

4. Run the split command:
   ```
   trestle split -f <file> -e '<element_path>'
   ```

5. Show the directory structure after the split.

6. Tell the user:
   - Split files can be edited independently.
   - Use `trestle merge` to recombine.
   - Use `trestle describe` to check split files.
