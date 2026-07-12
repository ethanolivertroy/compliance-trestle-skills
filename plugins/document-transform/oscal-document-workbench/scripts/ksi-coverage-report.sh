#!/usr/bin/env bash
# Report FedRAMP 20x KSI coverage for an OSCAL SSP using the 2026 Consolidated Rules.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$script_dir/ksi-coverage-report.py" "$@"
