#!/usr/bin/env bash
# Usage: ./setup.sh <org>/<repo>
# Merge queues need an org-owned repo (public is fine on the free plan); personal repos don't get them.
set -euo pipefail
repo=$1
cd "$(dirname "$0")"
git init -q -b main && git add -A && git commit -qm "init"
gh repo create "$repo" --public --source . --push
gh api -X PATCH "repos/$repo" -F allow_auto_merge=true --silent   # scenario.sh enqueues via --auto
# only gate-after is required: "before" runs in the queue for comparison but can't block it
gh api -X POST "repos/$repo/rulesets" --input - <<'JSON'
{
  "name": "main-merge-queue",
  "target": "branch",
  "enforcement": "active",
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "merge_queue", "parameters": {
        "merge_method": "MERGE", "grouping_strategy": "ALLGREEN",
        "max_entries_to_build": 5, "min_entries_to_merge": 1, "max_entries_to_merge": 5,
        "min_entries_to_merge_wait_minutes": 0, "check_response_timeout_minutes": 30 } },
    { "type": "required_status_checks", "parameters": {
        "strict_required_status_checks_policy": false,
        "required_status_checks": [ { "context": "gate-after" } ] } }
  ]
}
JSON
echo "done: https://github.com/$repo"
