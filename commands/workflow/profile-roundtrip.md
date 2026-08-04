---
description: Full profile authoring workflow - generate, edit, and assemble
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
disable-model-invocation: true
argument-hint: "<profile_name>"
---

Run the full profile authoring roundtrip workflow.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for the profile name.
   If the name is missing, list available profiles and ask the user to choose.

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

4. **Generate phase**:
   ```
   trestle author profile-generate --name <profile_name> --output <profile_name>-markdown
   ```

5. Show the structure. Tell the user:
   - `values:` shows catalog defaults. `profile-values:` are overrides.
   - `x-trestle-sections` maps section names.
   - Profile-specific sections can be added.
   - The control statement is read-only. It comes from the catalog.

6. **Edit phase**: help the user:
   - Show a sample control with profile additions.
   - Tell the user how to set profile-values for parameters.
   - Tell the user how to add sections such as implementation guidance or expected evidence.

7. **Assemble phase**:
   ```
   trestle author profile-assemble --markdown <profile_name>-markdown --output <profile_name> --set-parameters
   ```

8. If the user wants, resolve the profile to see effective controls:
   ```
   trestle author profile-resolve --name <profile_name> --output <profile_name>-resolved
   ```

9. Validate and report results.
