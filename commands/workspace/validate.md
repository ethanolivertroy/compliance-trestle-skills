---
description: Validate OSCAL models in the Trestle workspace
allowed-tools: Bash, Read, Glob
user-invocable: true
argument-hint: "[--all | --type <type> | --name <name>]"
---

Validate OSCAL models in the Compliance Trestle workspace.

## Steps

1. Check that you are in a trestle workspace. Look for a `.trestle/` directory.

2. Set the validation scope from $ARGUMENTS:
   - No arguments or `--all`: validate all models with `trestle validate -a`
   - `--type <type>`: validate all models of a type with `trestle validate -t <type>`
   - `--name <name> --type <type>`: validate a specific model with `trestle validate -t <type> -n <name>`
   - A file path: validate a specific file with `trestle validate -f <path>`

3. Run the validation command and capture output.

4. Parse the results:
   - Report which models passed validation.
   - Report any validation errors with details.
   - Trestle runs these built-in validators (registered in `ValidatorFactory`):
     - **duplicates**: checks for duplicate UUIDs across the model
     - **refs**: checks that internal references resolve correctly
     - **links**: checks that link hrefs are reachable
     - **catalog**: catalog-specific structural rules
     - **rules** (rule-parameters): checks rule parameter consistency in component definitions
     - **all**: runs all of the validators above together

5. If validation fails, suggest corrective actions based on the error type.

6. To validate one element in a file after a split, tell the user about `trestle partial-object-validate -f <file> -e <element>` as a targeted alternative.

7. Show a summary: total models checked, passed, failed.
