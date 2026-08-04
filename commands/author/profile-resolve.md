---
description: Resolve a profile to produce a flattened catalog
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<profile_name> <output_catalog>"
---

Resolve a profile to produce its resolved profile catalog.
The result is a flattened catalog with all modifications applied.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `profile_name` (`--name`): profile to resolve
   - `output_catalog` (`--output`): name for the resolved catalog

3. Run:
   ```
   trestle author profile-resolve --name <profile_name> --output <output_catalog>
   ```

4. This makes a JSON catalog that shows the fully resolved view:
   - All imported controls are included.
   - All parameter modifications are applied.
   - All profile additions are included.

5. The resolved catalog appears in `catalogs/<output_catalog>/catalog.json`.

6. Note: this does not use markdown. It is a direct JSON-to-JSON operation.

7. Use the resolved catalog to see effective controls after all profile changes.
   You can also use it as input to SSP generation or for distribution.
