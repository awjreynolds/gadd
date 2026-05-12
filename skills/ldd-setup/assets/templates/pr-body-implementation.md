## Issue

Implements {ticket}

## Approved Artifacts

- PRD: `docs/tickets/{ticket}/prd.md`
- SDD: `docs/tickets/{ticket}/sdd.md`
- Plan: `docs/tickets/{ticket}/plan.md`
- Plan HTML: `docs/tickets/{ticket}/plan.html`

## ADRs

{adr_links}

## Plan Conformance

Summarize implementation against the approved plan. Do not rewrite the plan here.

| Plan slice | Status | Notes / variance |
| --- | --- | --- |
|  | Done / Partial / Not done |  |

Variance rule: explain any file/module/test deviation from the plan. If the variance changes architecture or scope, stop and update the SDD/plan before requesting implementation review.

## Test / Check Summary

{test_summary}

## Acceptance Criteria Evidence

| Acceptance criterion | Evidence |
| --- | --- |
|  |  |

## Review Boundaries

- Review implementation correctness against the approved PRD, SDD, and plan.
- Do not use this PR to approve new product scope.
- Do not accept new architecture decisions unless the SDD/ADR links were updated first.

## Reviewer Prompt

Primary question: Does this implementation follow the approved plan?

Please review in this order:

1. Does the implementation follow the approved plan slices?
2. Are any variances justified and still inside the approved SDD?
3. Do tests/checks prove the acceptance criteria and contracts?
4. Is there any hidden scope or architecture drift that should go back through LDD design/planning?
