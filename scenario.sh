#!/usr/bin/env bash
# Opens 3 PRs and auto-enqueues them. PR 2 fails only inside the queue, which invalidates
# the group stacked behind it and forces a rebuild: the case that piles up stale runs.
set -euo pipefail
cd "$(dirname "$0")"
git checkout -q main && git pull -q
for i in 1 2 3; do
  b="demo-$i-$(date +%s)"
  git checkout -q -b "$b" main
  echo "change $i $(date)" >> libs/a/README.md
  [[ $i == 2 ]] && touch libs/b/FAIL_E2E_IN_QUEUE
  git add -A && git commit -qm "demo change $i"
  git push -q -u origin "$b"
  gh pr create --fill --head "$b"
  gh pr merge "$b" --auto --merge   # joins the queue once its own PR checks pass
done
git checkout -q main
echo "watch: gh run list --event merge_group   (or the Actions tab)"
