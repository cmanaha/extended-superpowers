#!/usr/bin/env bash
# ci.sh — the quality spine, green from commit one.
# Runs locally and in GitHub Actions. Fail fast; print what failed.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
step() { printf '\n=== %s ===\n' "$1"; }

step "1. Manifest validation (claude plugin validate)"
if command -v claude >/dev/null 2>&1; then
  claude plugin validate ./plugins/extended-superpowers || fail=1
else
  echo "claude CLI not found — skipping (CI installs it)."
fi

step "2. JSON sanity"
for f in .claude-plugin/marketplace.json \
         plugins/extended-superpowers/.claude-plugin/plugin.json \
         plugins/extended-superpowers/hooks/hooks.json; do
  if python3 -m json.tool "$f" >/dev/null; then echo "ok: $f"; else echo "bad json: $f"; fail=1; fi
done

step "3. Shell lint (shellcheck)"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck scripts/ci.sh .githooks/commit-msg plugins/extended-superpowers/hooks/*.sh || fail=1
else
  echo "shellcheck not found — skipping (CI installs it)."
fi

step "4. Skill front-matter present"
while IFS= read -r skill; do
  if head -1 "$skill" | grep -q '^---$'; then echo "ok: $skill"; else echo "missing front-matter: $skill"; fail=1; fi
done < <(find plugins -name SKILL.md)

step "5. Trigger / acceptance tests"
shopt -s nullglob
trigger_tests=(tests/trigger/*.sh)
if [ ${#trigger_tests[@]} -eq 0 ]; then
  echo "[tier] no trigger tests yet (added with the acceptance-tests skill — see plan)."
else
  echo "[tier] ${#trigger_tests[@]} trigger test(s) present"
  for t in "${trigger_tests[@]}"; do echo "run: $t"; bash "$t" || fail=1; done
fi

step "6. Authorship guard (no AI attribution in git history)"
if git rev-parse HEAD >/dev/null 2>&1; then
  if git log --format='%B' | grep -qiE \
    '^[[:space:]]*co-authored-by:|generated with \[?claude|🤖[[:space:]]*generated|noreply@anthropic\.com'; then
    echo "AI attribution found in commit history"; fail=1
  else
    echo "ok: clean history (author Carlos Manzanedo Rueda)"
  fi
else
  echo "no commits yet — skipping"
fi

if [ "$fail" -ne 0 ]; then echo -e "\n✗ ci.sh FAILED"; exit 1; fi
echo -e "\n✓ ci.sh passed"
