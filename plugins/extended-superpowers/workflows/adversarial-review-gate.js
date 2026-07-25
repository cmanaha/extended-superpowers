export const meta = {
  name: 'adversarial-review-gate',
  description: 'Run the full named-lens adversarial review over a spec, plan, or implementation and return a GO / NO-GO gate verdict',
  whenToUse: 'At the spec-to-plan, plan-to-code, or code-to-merge gate, when an artifact must be refuted by fresh eyes before it advances. Pass {artifact, kind, principle}. kind is "spec", "plan", or "implementation".',
  phases: [
    { title: 'Review', detail: 'one fresh reviewer per named lens, enumerate-only' },
    { title: 'Gate', detail: 'GO only when zero BLOCKER and zero MAJOR remain' },
  ],
}

// The lens contract, lifted verbatim from skills/adversarial-review/SKILL.md.
// In the skill this table is prose the model is trusted to honour; here it is
// the loop bound, so a lens cannot be silently dropped.
const LENSES = {
  spec: [
    'factual-grounding',
    'completeness',
    'design-flaw/race',
    'testability/DoD',
  ],
  plan: [
    'spec-coverage+guardrails',
    'testing+trackability',
    'sequencing+anti-hubris',
  ],
}

const FINDINGS_SCHEMA = {
  type: 'object',
  required: ['lens', 'verdict', 'findings'],
  properties: {
    lens: { type: 'string', description: 'the single lens this reviewer was assigned' },
    verdict: { type: 'string', description: 'one line: does the artifact survive this lens?' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['severity', 'where', 'problem', 'fix'],
        properties: {
          severity: { type: 'string', enum: ['BLOCKER', 'MAJOR', 'MINOR'] },
          where: { type: 'string', description: 'file:line or section anchor' },
          problem: { type: 'string' },
          fix: { type: 'string' },
        },
      },
    },
  },
}

const artifact = args && args.artifact
const kind = args && args.kind
const principle = (args && args.principle) || ''

// Design by contract: fail at the point of detection, with the contract stated.
if (!artifact || !kind) {
  throw new Error(
    'adversarial-review-gate requires {artifact, kind}. ' +
      'artifact = path to the spec, plan, or changed-code root. ' +
      'kind = "spec" | "plan" | "implementation".',
  )
}
if (kind !== 'implementation' && !LENSES[kind]) {
  throw new Error(
    'unknown kind "' + kind + '" — expected "spec", "plan", or "implementation".',
  )
}

function brief(lens, extra) {
  return [
    'You are reviewing ONE artifact through EXACTLY ONE lens: ' + lens + '.',
    '',
    'Artifact: ' + artifact,
    principle ? 'Governing principle to apply: ' + principle : '',
    '',
    'Your job is to REFUTE this artifact through your lens. Default to finding',
    'problems. A cooperative "looks good" is a failed review.',
    '',
    'ENUMERATE, DO NOT FIX. You must not modify any file. Report findings only.',
    'Grade each finding BLOCKER, MAJOR, or MINOR, and anchor it to a concrete',
    'location. Every finding needs a specific fix, not a vague concern.',
    extra || '',
  ]
    .filter(Boolean)
    .join('\n')
}

function tally(reports) {
  const all = []
  for (const r of reports) {
    if (!r || !r.findings) continue
    for (const f of r.findings) all.push({ ...f, lens: r.lens })
  }
  return all
}

function blocking(findings) {
  return findings.filter((f) => f.severity === 'BLOCKER' || f.severity === 'MAJOR')
}

let findings = []
let skipped = null

if (kind === 'implementation') {
  // The binding order: spec-compliance FIRST, then code-quality. The skill
  // states this and lists "code-quality review started before spec-compliance
  // is clean" as a red flag; here the sequencing is structural, and a failing
  // compliance pass genuinely short-circuits the quality pass.
  phase('Review')
  log('implementation gate: spec-compliance first, code-quality only if it is clean')

  const compliance = await agent(
    brief(
      'spec-compliance',
      'Check ONLY whether the code matches its spec: missing requirements and ' +
        'unrequested extras. Correctness and style are NOT your lens.',
    ),
    { label: 'lens:spec-compliance', phase: 'Review', agentType: 'spec-compliance-reviewer', schema: FINDINGS_SCHEMA },
  )

  findings = tally([compliance])

  if (blocking(findings).length > 0) {
    skipped = 'code-quality'
    log('spec-compliance is not clean — code-quality lens deliberately not run')
  } else {
    const quality = await agent(
      brief(
        'code-quality',
        'Spec-compliance is already clean. Find correctness and quality defects: ' +
          'bugs, races, silent failures, drift from nearby conventions, missing edge cases.',
      ),
      { label: 'lens:code-quality', phase: 'Review', agentType: 'code-quality-reviewer', schema: FINDINGS_SCHEMA },
    )
    findings = tally([compliance, quality])
  }
} else {
  // Spec and plan lenses are independent, so they fan out. The loop is bound by
  // the lens table: dropping a lens requires editing the contract, not just
  // forgetting.
  phase('Review')
  const lenses = LENSES[kind]
  log('dispatching the full ' + kind + ' lens set (' + lenses.length + '): ' + lenses.join(', '))

  const reports = await parallel(
    lenses.map((lens) => () =>
      agent(brief(lens), {
        label: 'lens:' + lens,
        phase: 'Review',
        agentType: 'adversarial-reviewer',
        schema: FINDINGS_SCHEMA,
      }),
    ),
  )

  const returned = reports.filter(Boolean)
  if (returned.length < lenses.length) {
    // No silent caps: a lens that died is not a lens that passed.
    log(
      'WARNING: ' + (lenses.length - returned.length) + ' of ' + lenses.length +
        ' lenses returned nothing. The gate cannot be GO on an incomplete lens set.',
    )
  }
  findings = tally(returned)
  if (returned.length < lenses.length) skipped = 'incomplete-lens-set'
}

phase('Gate')
const blockers = blocking(findings)
const gate = blockers.length === 0 && !skipped ? 'GO' : 'NO-GO'
log(
  'gate: ' + gate + ' — ' + blockers.length + ' blocking finding(s), ' +
    findings.length + ' total',
)

return {
  gate,
  kind,
  artifact,
  skipped,
  counts: {
    blocker: findings.filter((f) => f.severity === 'BLOCKER').length,
    major: findings.filter((f) => f.severity === 'MAJOR').length,
    minor: findings.filter((f) => f.severity === 'MINOR').length,
  },
  findings,
}
