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
  shellcheck scripts/*.sh .githooks/commit-msg plugins/extended-superpowers/hooks/*.sh tests/trigger/*.sh tests/install/*.sh || fail=1
else
  echo "shellcheck not found — skipping (CI installs it)."
fi

step "4. Skill front-matter present"
while IFS= read -r skill; do
  if head -1 "$skill" | grep -q '^---$'; then echo "ok: $skill"; else echo "missing front-matter: $skill"; fail=1; fi
done < <(find plugins -name SKILL.md)

step "5. Workflow script syntax"
# The platform checks nothing here: a workflow script with a syntax error passes
# `claude plugin validate`, installs cleanly, and leaves the plugin enabled — it
# fails only when a user invokes the gate (experiment E02, decisions.jsonl line 4).
# So this repo must lint its own workflow scripts.
#
# A plain `node --check` is NOT sufficient and gives a false pass: workflow
# scripts carry `export const meta` alongside top-level `await` and `return`,
# which no single node parse mode accepts. De-export and wrap in an async
# function so all three are legal, then syntax-check that. Verified RED on a
# deliberately broken script, GREEN on the real one.
shopt -s nullglob
wf_scripts=(plugins/*/workflows/*.js)
if [ ${#wf_scripts[@]} -eq 0 ]; then
  echo "no workflow scripts to check"
else
  wf_tmp=$(mktemp -d)
  trap 'rm -rf "$wf_tmp"' EXIT
  for w in "${wf_scripts[@]}"; do
    { echo '(async function(){'; sed 's/^export const meta/const meta/' "$w"; echo '})'; } > "$wf_tmp/check.js"
    if node --check "$wf_tmp/check.js" 2>"$wf_tmp/err"; then
      echo "ok: $w"
    else
      echo "syntax error in workflow: $w"; sed -n '1,6p' "$wf_tmp/err"; fail=1
    fi
    # meta.name is what names the slash command (/<plugin>:<meta.name>), not the
    # filename — so a missing meta.name ships an unreachable workflow.
    if ! grep -qE "^[[:space:]]*name:[[:space:]]*'[^']+'" "$w"; then
      echo "workflow missing a meta.name: $w"; fail=1
    fi
  done
fi

step "6. Trigger / acceptance tests"
shopt -s nullglob
trigger_tests=(tests/trigger/*.sh)
if [ ${#trigger_tests[@]} -eq 0 ]; then
  echo "[tier] no trigger tests yet (added with the acceptance-tests skill — see plan)."
else
  echo "[tier] ${#trigger_tests[@]} trigger test(s) present"
  for t in "${trigger_tests[@]}"; do echo "run: $t"; bash "$t" || fail=1; done
fi

step "7. Install smoke test (sandboxed marketplace add + plugin install)"
bash tests/install/marketplace-install.test.sh || fail=1

step "8. No-AI-attribution guard (git history)"
if git rev-parse HEAD >/dev/null 2>&1; then
  if git log --format='%B' | grep -qiE \
    'co-authored-by:.*(claude|anthropic|openai|gpt|copilot|gemini|cursor|\bai\b)|generated with \[?(claude|ai)|🤖|noreply@anthropic\.com|assisted by (claude|gpt|copilot|an ai)'; then
    echo "AI attribution found in commit history"; fail=1
  else
    echo "ok: no AI attribution in commit history"
  fi
else
  echo "no commits yet — skipping"
fi

if [ "$fail" -ne 0 ]; then echo -e "\n✗ ci.sh FAILED"; exit 1; fi
echo -e "\n✓ ci.sh passed"
