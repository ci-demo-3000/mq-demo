#!/usr/bin/env bash
# Fake Vercel preview deploy. Usage: mock-deploy.sh <app>. Logs to stderr, prints only the URL on stdout.
set -euo pipefail
app=$1
echo "building $app @ ${GITHUB_SHA::7} (run $GITHUB_RUN_ID)..." >&2
sleep "${DEPLOY_SECONDS:-45}"
[[ -f "apps/$app/FAIL_DEPLOY" ]] && { echo "::error::deploy failed" >&2; exit 1; }
# exits 0 without a URL, like a deploy that "succeeds" silently
[[ -f "apps/$app/SILENT_FAIL_DEPLOY" ]] && exit 0
echo "https://$app-${GITHUB_SHA::7}-$GITHUB_RUN_ID.mock.vercel.app"
