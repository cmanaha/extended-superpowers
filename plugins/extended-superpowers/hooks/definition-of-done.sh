#!/usr/bin/env bash
# Definition-of-Done gate — tooling-enforced completion.
#
# The model cannot self-certify "done"; this script certifies it. It reads a
# per-project `dod.config` that declares each criterion as `required` or `n/a`,
# runs every REQUIRED check, and emits GO / NO-GO. Any required NO-GO fails the
# whole gate (exit 1). Run before any completion or release claim.
#
# Usage: definition-of-done.sh [path/to/dod.config]   (default: ./dod.config)
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || dirname "$0")" || exit 1
cfg="${1:-dod.config}"
[ -f "$cfg" ] || { echo "no dod.config found at: $cfg"; exit 2; }

req ()    { grep -qE "^$1[[:space:]]*=[[:space:]]*required" "$cfg"; }
nogo=0
result () { if [ "$2" -eq 0 ]; then echo "  GO    $1"; else echo "  NO-GO $1"; nogo=1; fi; }

echo "Definition-of-Done gate ($cfg)"

if req ci_green; then
  bash scripts/ci.sh >/tmp/dod-ci.log 2>&1; result "ci_green (scripts/ci.sh)" $?
fi

if req grooming; then
  if grep -RIlnE 'TBD|FIXME|XXX' plugins/*/skills/*/SKILL.md >/dev/null 2>&1; then
    result "grooming (no placeholders in shipped skills)" 1
  else
    result "grooming (no placeholders in shipped skills)" 0
  fi
fi

if req acceptance_green; then
  miss=0
  for d in plugins/*/skills/*/; do
    s=$(basename "$d")
    [ -f "tests/trigger/$s.trigger.sh" ] || { echo "      (no trigger test for shipped skill: $s)"; miss=1; }
  done
  result "acceptance_green (every shipped skill has a trigger test)" "$miss"
fi

for c in lint coverage telemetry; do
  if req "$c"; then
    echo "  NO-GO $c (marked required but no check is defined here — add a check or mark n/a)"
    nogo=1
  fi
done

echo
if [ "$nogo" -eq 0 ]; then echo "✓ Definition of Done: GO"; exit 0; fi
echo "✗ Definition of Done: NO-GO"; exit 1
