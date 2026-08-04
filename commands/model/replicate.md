---
description: Replicate (copy or rename) an OSCAL model in the workspace
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<type> <source_name> <new_name>"
---

Replicate an OSCAL model to make a copy with a new name.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `type`: the model type (catalog, profile, or another supported type)
   - `source_name` (`-n`): the existing model name to copy
   - `new_name` (`-o`): the name for the new copy

3. Run the replicate command:
   ```
   trestle replicate <type> -n <source_name> -o <new_name>
   ```

4. This copies the full model directory structure with new UUIDs.

5. Show the new model location. Confirm success.

6. Note: all UUIDs are regenerated in the copy. Each UUID must be unique.
