---
description: Import an existing OSCAL document into the workspace
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<file_path_or_url> <name>"
---

Import an existing OSCAL document into the Trestle workspace.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `file`: path to the OSCAL file (absolute, relative, or URL). Supported protocols: file:///, https://, sftp://
   - `name`: the name or alias for the imported model

3. If the source is a local path, check that the file exists.
   Check that the extension is `.json`, `.yaml`, or `.yml`.

4. Run the import command:
   ```
   trestle import -f <file> -o <name>
   ```

5. The import detects the model type and validates the file.

6. If import fails, tell the user the error:
   - Validation failure: describe what is wrong with the OSCAL document.
   - File not found: check the path.
   - File inside the trestle dir: import from outside the workspace.

7. On success, show where the model was imported. Suggest next steps:
   - Use `trestle describe` to examine the model.
   - Use `trestle split` to break the model for editing.
   - Use author commands such as catalog-generate or profile-generate for markdown authoring.

8. **If the imported model is a profile**, warn the user about import resolution:
   - Read the profile JSON and check `profile.imports[].href`.
   - If any import uses `trestle://catalogs/<name>/...`, check that that catalog exists in the workspace.
   - If it does not exist, tell the user to import the referenced catalog or update the href with `trestle href`.
   - This is required. Author commands such as profile-generate fail when imports do not resolve.
