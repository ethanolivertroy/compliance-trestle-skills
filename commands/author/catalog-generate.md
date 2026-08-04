---
description: Generate markdown from an OSCAL catalog for editing
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<catalog_name> <output_dir>"
---

Generate editable markdown files from an OSCAL catalog.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `catalog_name` (`--name`): name of the catalog in the workspace
   - `output_dir` (`--output`): directory for markdown output
   - Optional: `--yaml` / `-y`: path to a YAML header file
   - Optional: `--overwrite-header-values`: overwrite existing header values
   - Optional: `--force-overwrite`: erase existing markdown before you regenerate

3. Check that the catalog exists at `catalogs/<catalog_name>/catalog.json`.

4. Run:
   ```
   trestle author catalog-generate --name <catalog_name> --output <output_dir>
   ```

5. Show the generated markdown structure:
   - One `.md` file per control
   - Subdirectories for control groups
   - YAML header with `x-trestle-set-params` for parameters

6. Tell the user what they can edit:
   - Parameter values in the YAML header (`x-trestle-set-params`)
   - Control statement prose (add or change items)
   - Control guidance
   - New items in the statement

7. Suggest next steps. Edit the markdown. Then run `catalog-assemble` to make updated JSON.
