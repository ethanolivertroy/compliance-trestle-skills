---
description: Generate markdown from an OSCAL profile for editing
allowed-tools: Bash, Read, Glob, Grep
user-invocable: true
argument-hint: "<profile_name> <output_dir>"
---

Generate editable markdown from an OSCAL profile resolved catalog.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `profile_name` (`--name`): name of the profile in the workspace
   - `output_dir` (`--output`): directory for markdown output
   - Optional: `--yaml` / `-y`: YAML header file
   - Optional: `--overwrite-header-values`: overwrite existing headers
   - Optional: `--force-overwrite`: erase and regenerate

3. **Pre-check: make sure profile imports resolve.**
   Read the profile JSON at `profiles/<profile_name>/profile.json`.
   Read `profile.imports[].href`.
   For each import:
   - If the href is `trestle://catalogs/<name>/catalog.json`, check that `catalogs/<name>/` exists in the workspace.
   - If the href is an external URL, warn the user that the URL must be accessible.
   - If a referenced catalog does not exist, tell the user to do one of these:
     a. Import the catalog under the expected name: `trestle import -f <source> -o <expected_name>`
     b. Update the profile href: `trestle href -n <profile_name> -hr trestle://catalogs/<actual_name>/catalog.json`
   - Do not continue until the imports resolve. Generate fails if they do not resolve.

4. Run:
   ```
   trestle author profile-generate --name <profile_name> --output <output_dir>
   ```

5. Show the markdown structure. Each control has:
   - `values:` (from the catalog) and `profile-values:` (profile overrides) in the YAML header
   - `x-trestle-sections` mapping section short names to display names
   - Control statement (read-only from the catalog)
   - Editable sections for profile additions

6. Tell the user how to edit:
   - Set `profile-values:` to override catalog parameter values.
   - Add content to profile-specific sections.
   - The `values:` field shows catalog defaults. It is informational.

7. Next steps: edit, then run `profile-assemble`.
