#!/usr/bin/env bash
# Mock of `nx show projects --affected --json`: every project under apps/ counts as affected.
set -euo pipefail
ls apps | jq -R . | jq -sc .
