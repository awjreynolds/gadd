## Issue

Implements {work_item_id}

This PR is the GitHub-first managed projection for implementation review. The repo-local Work Item ledger remains canonical for implementation, verification, and closure state.

## GADD Traceability

- Work Item: `{work_item_id}`
- Work Item type: `{work_item_type}`
- Local ledger: `gadd/work-items/{work_item_id}/ledger.yml`
- Boundary source: `{boundary_source}`

## Approved Artifacts

- PRD: `{prd_path}`
- Triage outcome: `{triage_projection_url}`
- SDD: `gadd/work-items/{work_item_id}/sdd.md`
- Plan: `gadd/work-items/{work_item_id}/plan.md`
- Plan HTML: `gadd/work-items/{work_item_id}/plan.html`

## ADRs

{adr_links}

## Plan Conformance

Summarize implementation against the approved plan. Do not rewrite the plan here.

| Plan slice | Status | Notes / variance |
| --- | --- | --- |
|  | Done / Partial / Not done |  |

Variance rule: explain any file/module/test deviation from the plan. If the variance changes architecture or scope, stop and update the SDD/plan before requesting implementation review.

## Documentation Impact

Status: updated / not_needed / blocked

- Documentation changed:
- Rationale:

If documentation impact is `blocked`, do not request implementation review until the blocking question is resolved.

## Test / Check Summary

{test_summary}

## Acceptance Criteria Evidence

| Acceptance criterion | Evidence |
| --- | --- |
|  |  |

## Review Boundaries

- Review implementation correctness against the approved boundary source, SDD, and plan.
- Do not use this PR to approve new product scope.
- Do not accept new architecture decisions unless the SDD/ADR links were updated first.

## Reviewer Prompt

Primary question: Does this implementation follow the approved plan?

Please review in this order:

1. Does the implementation follow the approved plan slices?
2. Are any variances justified and still inside the approved SDD?
3. Is documentation impact recorded and correct for the behavior changed?
4. Do tests/checks prove the acceptance criteria and contracts?
5. Is there any hidden scope or architecture drift that should go back through GADD design/planning?

## Managed Projection Rule

GADD may update this body only after explicit human confirmation and an external drift check. Closing this PR does not close the GADD Work Item; `/gadd:verify` and `/gadd:close` own that lifecycle.

<!-- gadd:managed-body-version=1 -->
