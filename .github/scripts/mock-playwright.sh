#!/usr/bin/env bash
# Fake `playwright test` for <app>-e2e. Usage: BASE_URL=... mock-playwright.sh <app>.
# Fails if BASE_URL isn't this app's deployment from this run.
set -euo pipefail
app=$1
url=${BASE_URL:-}
expected="https://$app-${GITHUB_SHA::7}-$GITHUB_RUN_ID."
echo "$app-e2e: baseURL '$url'"
[[ -n $url ]] || { echo "::error::no deployment URL"; exit 1; }
[[ $url == "$expected"* ]] || { echo "::error::wrong/stale env, expected ${expected}*"; exit 1; }
echo "Running 3 tests using 2 workers"
sleep "${E2E_SECONDS:-45}"
echo "  ✓  1 [chromium] › $app.spec.ts:5:3 › loads the home page"
echo "  ✓  2 [chromium] › $app.spec.ts:12:3 › navigates to a detail page"
# fails only in the queue, so the PR itself stays green and can be enqueued
if [[ -f "apps/$app/FAIL_E2E_IN_QUEUE" && $GITHUB_EVENT_NAME == merge_group ]]; then
  echo "  ✘  3 [chromium] › $app.spec.ts:20:3 › submits the form"
  echo "::error::1 failed, 2 passed"; exit 1
fi
echo "  ✓  3 [chromium] › $app.spec.ts:20:3 › submits the form"
echo "  3 passed"
