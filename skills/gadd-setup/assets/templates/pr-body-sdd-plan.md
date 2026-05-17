## Issue

References {work_item_id}

This PR is the GitHub-first managed projection for SDD and plan review. The repo-local ledger remains canonical for GADD phase state and approvals.

## GADD Traceability

- Work Item: `{work_item_id}`
- Work Item type: `{work_item_type}`
- Local ledger: `gadd/work-items/{work_item_id}/ledger.yml`
- Boundary source: `{boundary_source}`

## Review Package

- PRD: `{prd_path}`
- Triage outcome: `{triage_projection_url}`
- SDD: `gadd/work-items/{work_item_id}/sdd.md`
- Plan: `gadd/work-items/{work_item_id}/plan.md`
- Plan HTML: `gadd/work-items/{work_item_id}/plan.html`

## ADRs

{adr_links}

## What Changed

- Added or updated the SDD for the approved boundary source.
- Added or updated the implementation plan and rendered HTML review copy.
- Captured ADR links for durable architecture decisions.

## Traceability Checks

- [ ] SDD decisions trace back to the approved boundary source, existing code, or ADRs.
- [ ] Plan slices trace to approved acceptance or done criteria and SDD contracts.
- [ ] No product scope was added during design or planning.
- [ ] No architecture decision is introduced only in the plan.

## Known Review Risks

- Design gaps:
- Planning uncertainties:
- Open questions:

## Reviewer Prompt

Please review in this order:

1. Does the SDD correctly translate the approved boundary source into a design grounded in current code and ADRs?
2. Are any durable architecture decisions missing ADR coverage?
3. Does the plan implement the SDD without adding new design decisions?
4. Are the slices small enough to implement and review safely?

## Managed Projection Rule

GADD may update this body only after explicit human confirmation and an external drift check. Linear and Jira review projections are follow-on optional collaboration surfaces.

<!-- gadd:managed-body-version=1 -->
