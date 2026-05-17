---
name: gadd-verify
description: Run /gadd:verify on one implemented GADD Work Item to check whether it is ready to close. Use when the user says /gadd:verify, asks to verify a Work Item, asks whether a Work Item is ready to close, wants the verification.md report written, or says things like "run the checks", "the PR merged, is this verified?", "confirm this Work Item is done", or "check closure readiness". Verification reads ledger evidence, external implementation PR state, configured checks, and documentation impact, then writes verification.md and updates artifacts.verification plus closure.status. It is not a repository healthcheck and does not perform closure; it hands off to /gadd:close <work-item-id> on pass.
---

# /gadd:verify

Verify whether one implemented Work Item is ready for human-approved closure.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

Scope this command to Work Item closure only. It is not a repository health command, release gate, lint bundle, or broad project audit.

## Inputs

Run against exactly one Work Item:

```text
/gadd:verify <work-item-id>
```

If no Work Item ID is provided, stop and ask for one. Do not infer a target from unrelated modified files.

## Reads

- Work Item `ledger.yml`
- Work Item body
- parent Work Item `ledger.yml` when the target is a child Work Item
- approved inputs required by Work Item type
- implementation evidence
- implementation PR state when implementation evidence references a PR
- check evidence
- documentation impact evidence
- external drift metadata when configured
- optional GitNexus code-intelligence context when the approved plan or implementation evidence references it

Read the Work Item ledger before reading broader repo state. Use the Work Item ledger and parent ledger, when present, to locate the approved artifacts and expected evidence paths.

## Writes

- `verification.md` in the Work Item directory
- Work Item ledger `artifacts.verification`
- Work Item ledger `closure.status`
- compact Work Item ledger events for verification pass or failure

Do not write outside the Work Item directory and ledger except for the narrowly required local report path. Do not edit parent PRD, SDD, plan, or Work Item body from this command.

## Input Quality Gate

Required input standard before writing verification:

- exactly one implemented Work Item
- Work Item ledger implementation evidence and check evidence
- documentation impact evidence for the implemented Work Item
- implementation PR state is externally checked when implementation evidence references a PR
- approved inputs required by Work Item type and the Work Item body
- no unresolved external tracker drift when a tracker projection exists

Required approved inputs by Work Item type:

- `bug_fix` and `task`: approved triage outcome, implementation evidence, check evidence, documentation impact, external drift review.
- `engineering_change`: approved triage outcome, approved SDD, optional plan/decomposition artifacts if used, implementation evidence, check evidence, documentation impact, external drift review.
- `product_requirement`: approved PRD, approved SDD, approved plan, decomposition artifacts when used, implementation evidence, check evidence, documentation impact, external drift review.

If inputs fail this standard, write only a failed or override-required verification report when enough Work Item context exists; otherwise stop without mutation. The earliest GADD command that can repair missing implementation evidence is `/gadd:implement`; artifact drift routes to the owning `/gadd:scope`, `/gadd:design`, `/gadd:plan`, or `/gadd:triage` command.

Required evidence:

- Work Item ledger artifact path, acceptance or done criteria, parent link when present, blocked-by state, covered user stories, and plan slice when present
- parent ledger artifact statuses and paths for the approved PRD, SDD, and plan when required
- approved PRD, approved SDD, approved plan, approved triage outcome, and Work Item body as required by type
- implementation evidence from the Work Item ledger, local diff summary, commit/PR reference, or implementation notes recorded by `/gadd:implement`
- implementation PR evidence from the external tracker when a PR URL or number is recorded, including state, merge time, and merge commit when available
- check evidence from automated command output, validation output, or explicit manual verification notes
- documentation impact evidence with status `updated`, `not_needed`, or `blocked`, plus changed documentation paths or direct rationale
- External Issue drift metadata from `sync` fields or configured tracker metadata, including external update timestamps/body hashes when available

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Verification is specific to Work Item closure. It is not a general repository healthcheck.
- Verification checks documentation impact for the implemented Work Item only. It is not a repository-wide documentation audit.
- GitNexus may be used for optional blast-radius or change-impact checks, but missing GitNexus evidence must not block closure unless the approved plan explicitly required it.
- Keep implementation completion separate from Work Item closure.
- Treat external tracker state as a projection. If external metadata shows unresolved drift, block closure and ask for human reconciliation.
- Treat PR review, approval, merge, close, and branch deletion as external actions. Do not infer them from the conversation, local branch state, or the user's statement. If implementation evidence references a PR, read the external PR state before deciding verification.
- If the implementation PR is open, closed without merge, or cannot be checked, classify verification as `override_required`.
- If the implementation PR is merged and there is no conflict with recorded ledger state, record the observed `mergedAt` and merge commit in `verification.md` and the Work Item ledger as verification evidence; do not block merely because the ledger lacked that evidence before verification.
- If the implementation PR is merged but conflicts with recorded ledger merge evidence, classify verification as `override_required` and route to human reconciliation before closure can be recommended.
- Do not mutate external trackers, archive Work Items, close external Work Item projections, push branches, or create PRs from this command.
- Recommend closure only when the Work Item acceptance or done criteria, approved inputs, implementation evidence, documentation impact evidence, check evidence, and drift checks all support closure.
- If evidence is missing or checks failed, write the blocking reason to `verification.md` and leave `closure.status` unclosed.

## Workflow

1. Resolve the Work Item directory and read its `ledger.yml`.
2. Read the parent ledger referenced by the Work Item ledger when present.
3. Confirm required approved inputs by Work Item type.
4. Read the approved inputs and Work Item body.
5. Collect implementation evidence for the Work Item. Prefer ledger implementation evidence, then current diff/commit/PR evidence if referenced by the user.
6. If implementation evidence references a PR, read the external PR state. For GitHub, inspect at least `state`, `mergedAt`, and merge commit. Do not treat conversational claims such as "merged" as evidence.
7. Collect check evidence. Include exact commands and results when available; otherwise record the missing evidence as a blocker.
8. Collect documentation impact evidence. Accept only `updated`, `not_needed`, or `blocked`; require changed documentation paths for `updated` and a direct rationale for `not_needed`.
9. Optionally use GitNexus for blast-radius or change-impact checks when the approved plan or implementation evidence references it. Record missing or stale GitNexus evidence as a limitation unless the approved plan required fresh GitNexus evidence.
10. Review boundary/design/plan drift:
   - scope drift: implementation no longer fits the approved PRD or child acceptance criteria
   - design drift: implementation contradicts the approved SDD
   - plan drift: implementation does not match the approved plan slice or dependencies
11. Review external drift metadata. If External Issue or PR drift is unresolved, block closure and identify the human reconciliation needed.
12. Write or update `verification.md` as a human-readable report.
13. Update only the Work Item ledger verification state and compact event history.
14. Report the result and next action to the user.

## Verification Status Contract

Update `artifacts.verification.status` to exactly one of:

- `passed`: evidence is present, referenced implementation PR state is checked and recorded, documentation impact is satisfied, checks pass, no boundary/design/plan drift is detected, and no External Issue drift is unresolved.
- `failed`: closure must be blocked because evidence is missing, checks failed, or scope/design/plan drift is detected.
- `override_required`: closure must be blocked because the command cannot decide safely without human override, most commonly unresolved External Issue drift, unavailable approved artifacts, ambiguous evidence, or a requested external mutation.

Write the same value in `verification.md` as `Verification status: passed | failed | override_required` by choosing the actual value. Use `pending` only in templates before verification has run.

Update `closure.status` as follows:

- `verified` when verification status is `passed`
- `verification_required` when verification status is `failed`
- `verification_required` when verification status is `override_required`

Do not set `closure.status` to `archived` or `externally_closed` from this command.

## Blocking Conditions

Block Work Item closure when any of these are true:

- Work Item or Work Item ledger is missing
- parent ledger is missing when the verified Work Item is a child or parent roll-up
- required approved inputs for the Work Item type are missing or not approved
- implementation evidence is missing or does not trace to the Work Item acceptance or done criteria
- documentation impact evidence is missing, `blocked`, or inconsistent with a user-facing behavior, command behavior, public API, configuration, setup flow, template, integration contract, or operational workflow change
- implementation PR state is open, closed without merge, unavailable, or conflicts with recorded ledger merge evidence
- check evidence is missing, skipped without justification, or failed
- boundary/design/plan drift is detected
- External Issue drift is unresolved
- the user asks the command to mutate an external tracker without separate human confirmation

Every blocked result must include the blocking reasons in `verification.md` and in the user-facing summary.

## Report Contract

Write `verification.md` in the Work Item directory. It is human-readable review evidence; the Work Item ledger remains the machine-readable source of truth.

The report must include:

- summary with parent ID when present, Work Item ID, status, closure recommendation, timestamp, and verifier
- approved inputs with paths and approval status
- execution context that states `Boundary: Work Item closure only, not repository health`
- implementation evidence and acceptance-criteria traceability
- documentation impact status, changed documentation paths, or docs-not-needed rationale
- implementation PR state, merge evidence, and reconciliation status when a PR is referenced
- check evidence with command names, results, and skipped-check rationale
- drift review for ledger drift, approved artifact drift, scope/design/plan drift, and external tracker drift
- findings grouped as blockers, warnings, and notes
- closure decision for local done, local archive readiness, and external close readiness
- `Human confirmation required before external mutation: yes`

If verification passes, the report may recommend closure but must still say external mutation requires human confirmation.

## Ledger Update Contract

For a passed verification, update the Work Item ledger:

```yaml
artifacts:
  verification:
    path: gadd/work-items/.../verification.md
    status: passed
closure:
  status: verified
  verified_at: <iso8601-timestamp>
  override_reason: null
execution_context:
  next_command: /gadd:close <work-item-id>
  next_human_action: /gadd:close <work-item-id>
events:
  - at: <iso8601-timestamp>
    type: verification_passed
    actor: agent
```

For failed verification, update the Work Item ledger:

```yaml
artifacts:
  verification:
    path: gadd/work-items/.../verification.md
    status: failed
closure:
  status: verification_required
  verified_at: null
execution_context:
  next_command: /gadd:implement <work-item-id>
  next_human_action: reconcile failed verification
events:
  - at: <iso8601-timestamp>
    type: verification_failed
    actor: agent
```

For override-required verification, update the Work Item ledger:

```yaml
artifacts:
  verification:
    path: gadd/work-items/.../verification.md
    status: override_required
closure:
  status: verification_required
  verified_at: null
  override_reason: Human reconciliation required before closure.
execution_context:
  next_command: blocked
  next_human_action: resolve the verification override reason
events:
  - at: <iso8601-timestamp>
    type: verification_override_required
    actor: agent
```

Preserve existing unrelated ledger fields and events.

## External Tracker Rule

Never mutate external trackers without human confirmation. Verification may read configured external metadata, compare timestamps or body hashes, and recommend the next human action. It must not close, comment on, relabel, archive, or synchronize an External Issue by itself.

When External Issue drift exists, classify the result as `override_required` unless the Work Item ledger already records explicit human reconciliation evidence.

## Implementation PR State Rule

When Work Item implementation evidence records an implementation PR, for example `artifacts.implementation.evidence.implementation_pr`, a PR URL, or a PR number:

- Read the PR state from the external tracker before verification can pass.
- For GitHub, inspect the PR number or URL and check at least `state`, `mergedAt`, and merge commit.
- If the PR is open, verification status must be `override_required`; next human action is review and merge the implementation PR.
- If the PR is closed without merge, verification status must be `override_required`; next human action is reconcile the implementation path or return to `/gadd:implement <work-item-id>`.
- If the PR is merged and there is no conflict with recorded ledger state, verification records the observed `mergedAt` and merge commit as evidence and may pass when all other checks pass.
- If the PR is merged but conflicts with recorded ledger merge evidence, verification status must be `override_required`; next human action is reconcile implementation PR merge state.
- If the PR state cannot be checked, verification status must be `override_required`; next human action is restore tracker access or provide explicit human reconciliation evidence.

Never treat a conversational claim such as "merged" as merge evidence. The claim may explain why verification should check the external tracker, but it is not workflow state.

## Package Surface Contract

_Informational: package boundary, not a runtime rule. The runtime contract for verification is the Rules, Workflow, Verification Status Contract, Report Contract, and Ledger Update Contract sections above._

This initial package surface establishes `/gadd:verify` as an installable command. Later GADD slices may expand the detailed report contract, but they must preserve these invariants:

- repo-local `ledger.yml` remains the machine-readable source of truth
- `verification.md` remains the human-readable verification report
- verification may recommend closure but must not perform human-confirmed external mutations
- verify Work Items, not only implementation slices
- Work Item closure stays separate from implementation completion

## Stop Conditions

- missing Work Item
- missing required approved inputs for the Work Item type
- missing implementation evidence
- failed or missing check evidence
- unresolved external drift
- implementation PR state cannot be checked or conflicts with recorded ledger merge evidence
- requested external mutation without human confirmation
