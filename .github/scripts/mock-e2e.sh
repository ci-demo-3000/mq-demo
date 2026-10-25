#!/usr/bin/env bash
# Fake e2e run. Usage: BASE_URL=... mock-e2e.sh <lib>. Fails if BASE_URL isn't this lib's deployment from this run.
set -euo pipefail
lib=$1
url=${BASE_URL:-}
expected="https://$lib-${GITHUB_SHA::7}-$GITHUB_RUN_ID."
echo "e2e for $lib against '$url'"
[[ -n $url ]] || { echo "::error::no deployment URL"; exit 1; }
[[ $url == "$expected"* ]] || { echo "::error::wrong/stale env, expected ${expected}*"; exit 1; }
sleep "${E2E_SECONDS:-45}"
# fails only in the queue, so the PR itself stays green and can be enqueued
if [[ -f "libs/$lib/FAIL_E2E_IN_QUEUE" && $GITHUB_EVENT_NAME == merge_group ]]; then
  echo "::error::e2e failed in merge queue"; exit 1
fi
echo "e2e passed"
