#!/usr/bin/env bash
# Fake Vercel deploy. Usage: mock-deploy.sh <lib>. Logs to stderr, prints only the URL on stdout.
set -euo pipefail
lib=$1
echo "deploying $lib @ ${GITHUB_SHA::7} (run $GITHUB_RUN_ID)..." >&2
sleep "${DEPLOY_SECONDS:-45}"
[[ -f "libs/$lib/FAIL_DEPLOY" ]] && { echo "::error::deploy failed" >&2; exit 1; }
# exits 0 without a URL, like a deploy that "succeeds" silently
[[ -f "libs/$lib/SILENT_FAIL_DEPLOY" ]] && exit 0
echo "https://$lib-${GITHUB_SHA::7}-$GITHUB_RUN_ID.mock.vercel.app"
