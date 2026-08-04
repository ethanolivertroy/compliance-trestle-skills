---
description: View or update profile import hrefs to point to local workspace
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<profile_name> [--href <new_href>]"
---

View or update the import hrefs in a profile.
Point them to catalogs or profiles in the local trestle workspace.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `profile_name` (`-n` / `--name`): name of the trestle profile to check or change
   - `href` (`-hr` / `--href`, optional): new href value to set
   - `item` (`-i` / `--item`, optional): index of the import href to change (default: 0)

3. Check that the profile exists in `profiles/<profile_name>/`.

4. If `--href` is not provided, use **view mode**. List the import hrefs:
   - Read the profile and show all import entries with their href values.
   - Show which catalogs or profiles they reference.

5. If `--href` is provided, use **update mode**. Change the href:
   ```
   trestle href -n <profile_name> -hr <new_href>
   ```

   Common href formats:
   - `trestle://catalogs/my-catalog/catalog.json`: local workspace catalog
   - `trestle://profiles/my-profile/profile.json`: local workspace profile
   - `https://...`: remote OSCAL document URL

6. After the update, check that the referenced model exists in the workspace.
