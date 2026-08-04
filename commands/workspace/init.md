---
description: Start a new Compliance Trestle workspace
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "[--full | --local | --govdocs]"
---

Start a Compliance Trestle workspace in the working directory.

## Steps

1. Check if a `.trestle/` directory already exists in the working directory.
   If it does, tell the user that a trestle workspace already exists.
   Ask if they want to run init again.

2. Set the init mode from $ARGUMENTS:
   - `--full` (default): full workspace with dist/, model dirs, and .trestle/
   - `--local`: model dirs and .trestle/ only (no dist/)
   - `--govdocs`: only .trestle/ for document governance

3. Run the trestle init command:
   ```
   trestle init [mode_flag]
   ```

4. Check that the workspace was created. Look for a `.trestle/` directory.

5. Show the user the created directory structure. Use `ls` or a tree-like listing.

6. Tell the user what was created. Suggest next steps:
   - For `--full`: import or create OSCAL models, then use split/merge or author commands
   - For `--local`: import or create OSCAL models for local management
   - For `--govdocs`: set up document templates and governance rules
