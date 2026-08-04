---
description: Validate a specific OSCAL element in a file
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "<file> <element>"
---

Validate a specific OSCAL element in a file without validating the full model.

## Steps

1. Check that you are in a trestle workspace.

2. Read $ARGUMENTS for:
   - `file` (`-f` / `--file`): path to the file that contains the element
   - `element` (`-e` / `--element`): element path to validate, such as `catalog.metadata`
   - `--no-validators` / `-nv` (optional): run only basic schema validation, skip extra validators

3. Tell the user when partial validation is useful:
   - After you split a model, to validate individual sub-components
   - To check a specific section without full model assembly
   - For fast validation during iterative editing
   - When full validation is too slow or reports unrelated issues

4. Run the partial validation:
   ```
   trestle partial-object-validate -f <file> -e <element>
   ```

5. Report results:
   - If valid: confirm the element passes OSCAL schema validation.
   - If invalid: show the specific validation errors and their locations.
   - Suggest fixes for common validation issues.

6. Tell the user the difference from full validation (`trestle validate`):
   - `trestle validate` runs all validators (duplicates, refs, links, catalog rules, rule-parameters).
   - `partial-object-validate` validates one element against the OSCAL schema.
   - Use `-nv` to skip the extra validators and do schema-only checking.
