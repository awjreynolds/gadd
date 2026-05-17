# SDD: {title}

## Boundary Source

- Work Item type: `{work_item_type}`
- Approved boundary source: `{boundary_source}`
- Product Requirement issue: `{prd_issue}`
- Triage outcome projection: `{triage_projection_url}`

## Design Summary

{design_summary}

## Product Constraints

{product_constraints}

## Key Decisions

{key_decisions}

## ADRs

{adrs}

## Open Design Questions

{open_design_questions}

## GADD Status

- Phase: SDD approved / plan ready
- Canonical state: repo-local ledger
- External tracker role: GitHub issue projection for SDD visibility
- Relationship: for `product_requirement`, child of the Product Requirement issue; for `engineering_change`, projection of the approved triage outcome. Implementation child Work Items created by decomposition are children of this SDD issue when supported.

## GADD Traceability

- Work Item: `{work_item_id}`
- Work Item type: `{work_item_type}`
- Local ledger: `gadd/work-items/{work_item_id}/ledger.yml`

## GADD Links

- Ledger: `{ledger_path}`
- PRD: `{prd_path}`
- Triage outcome: `{triage_projection_url}`
- SDD: `{sdd_path}`
- Plan: `{plan_path}`

## External Notes

Add reviewer or stakeholder comments below. GADD must preserve externally edited notes unless the human explicitly approves reconciliation.

<!-- gadd:managed-body-version=1 -->
