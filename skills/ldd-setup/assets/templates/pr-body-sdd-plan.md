## Issue

References {ticket}

## Review Package

- PRD: `docs/tickets/{ticket}/prd.md`
- SDD: `docs/tickets/{ticket}/sdd.md`
- Plan: `docs/tickets/{ticket}/plan.md`
- Plan HTML: `docs/tickets/{ticket}/plan.html`

## ADRs

{adr_links}

## What Changed

- Added or updated the SDD for the approved PRD.
- Added or updated the implementation plan and rendered HTML review copy.
- Captured ADR links for durable architecture decisions.

## Traceability Checks

- [ ] SDD decisions trace back to the merged PRD, existing code, or ADRs.
- [ ] Plan slices trace to PRD acceptance criteria and SDD contracts.
- [ ] No product scope was added during design or planning.
- [ ] No architecture decision is introduced only in the plan.

## Known Review Risks

- Design gaps:
- Planning assumptions:
- Open questions:

## Reviewer Prompt

Please review in this order:

1. Does the SDD correctly translate the PRD into a design grounded in current code and ADRs?
2. Are any durable architecture decisions missing ADR coverage?
3. Does the plan implement the SDD without adding new design decisions?
4. Are the slices small enough to implement and review safely?
