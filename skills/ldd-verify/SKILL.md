---
name: ldd-verify
description: Run /ldd:verify for an implemented LDD child ticket. Use when the user says /ldd:verify or wants to verify child-ticket closure readiness after implementation completion.
---

# /ldd:verify

Verify whether one implemented child work item is ready for human-approved closure.

This command is a standalone, agent-agnostic LDD command. Follow this file directly; do not require any other installed skill.

Scope this command to child-ticket closure only. It is not a repository health command, release gate, lint bundle, or broad project audit.

## Inputs

Run against exactly one child work item:

```text
/ldd:verify <child-ticket-id>
```

If no child ticket ID is provided, stop and ask for one. Do not infer a target from unrelated modified files.

## Reads

- child ticket `ledger.yml`
- child ticket body
- parent ticket `ledger.yml`
- approved parent PRD, approved parent SDD, approved parent plan
- implementation evidence
- implementation PR state when implementation evidence references a PR
- check evidence
- external drift metadata when configured

Read the child ledger before reading broader repo state. Use the child ledger and parent ledger to locate the approved artifacts and expected evidence paths.

## Input Quality Gate

Required input standard before writing verification:

- exactly one implemented child ticket
- child ledger implementation evidence and check evidence
- implementation PR state is externally checked when implementation evidence references a PR
- approved parent PRD, approved parent SDD, approved parent plan, and child ticket body
- no unresolved external tracker drift when a tracker projection exists

If inputs fail this standard, write only a failed or override-required verification report when enough child context exists; otherwise stop without mutation. The earliest LDD command that can repair missing implementation evidence is `/ldd:implement`; parent artifact drift routes to the owning `/ldd:scope`, `/ldd:design`, or `/ldd:plan` command.

Required evidence:

- child ledger `artifacts.ticket.path`, child acceptance criteria, parent link, blocked-by state, covered user stories, and plan slice
- parent ledger artifact statuses and paths for the approved PRD, SDD, and plan
- approved PRD, approved SDD, approved plan, and child ticket body
- implementation evidence from the child ledger, local diff summary, commit/PR reference, or implementation notes recorded by `/ldd:implement`
- implementation PR evidence from the external tracker when a PR URL or number is recorded, including state, merge time, and merge commit when available
- check evidence from automated command output, validation output, or explicit manual verification notes
- external drift metadata from `sync` fields or configured tracker metadata, including external update timestamps/body hashes when available

## Writes

- `verification.md` in the child ticket directory
- child ledger `artifacts.verification`
- child ledger `closure.status`
- compact child ledger events for verification pass or failure

Do not write outside the child ticket directory and child ledger except for the narrowly required local report path. Do not edit parent PRD, SDD, plan, or child ticket body from this command.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Verification is specific to child-ticket closure. It is not a general repository healthcheck.
- Keep implementation completion separate from ticket closure.
- Treat external tracker state as a projection. If external metadata shows unresolved drift, block closure and ask for human reconciliation.
- Treat PR review, approval, merge, close, and branch deletion as external actions. Do not infer them from the conversation, local branch state, or the user's statement. If implementation evidence references a PR, read the external PR state before deciding verification.
- If the implementation PR is open, closed without merge, or cannot be checked, classify verification as `override_required`.
- If the implementation PR is merged and there is no conflict with recorded ledger state, record the observed `mergedAt` and merge commit in `verification.md` and the child ledger as verification evidence; do not block merely because the ledger lacked that evidence before verification.
- If the implementation PR is merged but conflicts with recorded ledger merge evidence, classify verification as `override_required` and route to human reconciliation before closure can be recommended.
- Do not mutate external trackers, archive child tickets, close external tickets, push branches, or create PRs from this command.
- Recommend closure only when the child acceptance criteria, approved parent artifacts, implementation evidence, check evidence, and drift checks all support closure.
- If evidence is missing or checks failed, write the blocking reason to `verification.md` and leave `closure.status` unclosed.

## Workflow

1. Resolve the child ticket directory and read its `ledger.yml`.
2. Read the parent ledger referenced by the child ledger.
3. Confirm the parent PRD, SDD, and plan are present and approved in the parent ledger.
4. Read the approved parent PRD, approved parent SDD, approved parent plan, and child ticket body.
5. Collect implementation evidence for the child ticket. Prefer child ledger implementation evidence, then current diff/commit/PR evidence if referenced by the user.
6. If implementation evidence references a PR, read the external PR state. For GitHub, inspect at least `state`, `mergedAt`, and merge commit. Do not treat conversational claims such as "merged" as evidence.
7. Collect check evidence. Include exact commands and results when available; otherwise record the missing evidence as a blocker.
8. Review scope/design/plan drift:
   - scope drift: implementation no longer fits the approved PRD or child acceptance criteria
   - design drift: implementation contradicts the approved SDD
   - plan drift: implementation does not match the approved plan slice or dependencies
9. Review external drift metadata. If external ticket or PR drift is unresolved, block closure and identify the human reconciliation needed.
10. Write or update `verification.md` as a human-readable report.
11. Update only the child ledger verification state and compact event history.
12. Report the result and next action to the user.

## Verification Status Contract

Update `artifacts.verification.status` to exactly one of:

- `passed`: evidence is present, referenced implementation PR state is checked and recorded, checks pass, no scope/design/plan drift is detected, and no external ticket drift is unresolved.
- `failed`: closure must be blocked because evidence is missing, checks failed, or scope/design/plan drift is detected.
- `override_required`: closure must be blocked because the command cannot decide safely without human override, most commonly unresolved external ticket drift, unavailable approved artifacts, ambiguous evidence, or a requested external mutation.

Write the same value in `verification.md` as `Verification status: passed | failed | override_required` by choosing the actual value. Use `pending` only in templates before verification has run.

Update `closure.status` as follows:

- `verified` when verification status is `passed`
- `verification_required` when verification status is `failed`
- `verification_required` when verification status is `override_required`

Do not set `closure.status` to `archived` or `externally_closed` from this command.

## Blocking Conditions

Block child-ticket closure when any of these are true:

- child ticket or child ledger is missing
- parent ledger is missing
- approved parent PRD, approved parent SDD, or approved parent plan is missing or not approved
- implementation evidence is missing or does not trace to the child acceptance criteria
- implementation PR state is open, closed without merge, unavailable, or conflicts with recorded ledger merge evidence
- check evidence is missing, skipped without justification, or failed
- scope/design/plan drift is detected
- external ticket drift is unresolved
- the user asks the command to mutate an external tracker without separate human confirmation

Every blocked result must include the blocking reasons in `verification.md` and in the user-facing summary.

## Report Contract

Write `verification.md` in the child ticket directory. It is human-readable review evidence; the child ledger remains the machine-readable source of truth.

The report must include:

- summary with parent ID, child ID, status, closure recommendation, timestamp, and verifier
- approved inputs with paths and approval status
- execution context that states `Boundary: child-ticket closure only, not repository health`
- implementation evidence and acceptance-criteria traceability
- implementation PR state, merge evidence, and reconciliation status when a PR is referenced
- check evidence with command names, results, and skipped-check rationale
- drift review for ledger drift, approved artifact drift, scope/design/plan drift, and external tracker drift
- findings grouped as blockers, warnings, and notes
- closure decision for local done, local archive readiness, and external close readiness
- `Human confirmation required before external mutation: yes`

If verification passes, the report may recommend closure but must still say external mutation requires human confirmation.

## Ledger Update Contract

For a passed verification, update the child ledger:

```yaml
artifacts:
  verification:
    path: docs/tickets/.../verification.md
    status: passed
closure:
  status: verified
  verified_at: 2026-05-13T00:00:00Z
  override_reason: null
events:
  - at: 2026-05-13T00:00:00Z
    type: verification_passed
    actor: agent
```

For failed verification, update the child ledger:

```yaml
artifacts:
  verification:
    path: docs/tickets/.../verification.md
    status: failed
closure:
  status: verification_required
  verified_at: null
events:
  - at: 2026-05-13T00:00:00Z
    type: verification_failed
    actor: agent
```

For override-required verification, update the child ledger:

```yaml
artifacts:
  verification:
    path: docs/tickets/.../verification.md
    status: override_required
closure:
  status: verification_required
  verified_at: null
  override_reason: Human reconciliation required before closure.
events:
  - at: 2026-05-13T00:00:00Z
    type: verification_override_required
    actor: agent
```

Preserve existing unrelated ledger fields and events.

## External Tracker Rule

Never mutate external trackers without human confirmation. Verification may read configured external metadata, compare timestamps or body hashes, and recommend the next human action. It must not close, comment on, relabel, archive, or synchronize an external ticket by itself.

When external drift exists, classify the result as `override_required` unless the child ledger already records explicit human reconciliation evidence.

## Implementation PR State Rule

When child implementation evidence records an implementation PR, for example `artifacts.implementation.evidence.implementation_pr`, a PR URL, or a PR number:

- Read the PR state from the external tracker before verification can pass.
- For GitHub, inspect the PR number or URL and check at least `state`, `mergedAt`, and merge commit.
- If the PR is open, verification status must be `override_required`; next human action is review and merge the implementation PR.
- If the PR is closed without merge, verification status must be `override_required`; next human action is reconcile the implementation path or return to `/ldd:implement <child-ticket-id>`.
- If the PR is merged and there is no conflict with recorded ledger state, verification records the observed `mergedAt` and merge commit as evidence and may pass when all other checks pass.
- If the PR is merged but conflicts with recorded ledger merge evidence, verification status must be `override_required`; next human action is reconcile implementation PR merge state.
- If the PR state cannot be checked, verification status must be `override_required`; next human action is restore tracker access or provide explicit human reconciliation evidence.

Never treat a conversational claim such as "merged" as merge evidence. The claim may explain why verification should check the external tracker, but it is not workflow state.

## Package Surface Contract

This initial package surface establishes `/ldd:verify` as an installable command. Later LDD slices may expand the detailed report contract, but they must preserve these invariants:

- repo-local `ledger.yml` remains the machine-readable source of truth
- `verification.md` remains the human-readable verification report
- verification may recommend closure but must not perform human-confirmed external mutations
- child-ticket closure stays separate from implementation completion

## Stop Conditions

- missing child ticket
- missing approved parent PRD, SDD, or plan
- missing implementation evidence
- failed or missing check evidence
- unresolved external drift
- implementation PR state cannot be checked or conflicts with recorded ledger merge evidence
- requested external mutation without human confirmation
