---
work_item: {work_item_id}
prd: docs/work-items/{work_item_id}/prd.md
sdd: docs/work-items/{work_item_id}/sdd.md
created: {date}
updated: {date}
plan_html: docs/work-items/{work_item_id}/plan.html
adrs: []
---

# Implementation Plan: {title}

## GADD Traceability

- Work Item: `{work_item_id}`
- Work Item type: `{work_item_type}`
- Local ledger: `docs/work-items/{work_item_id}/ledger.yml`

## Review Context

This plan translates the approved PRD and SDD into executable slices. It must not introduce new architecture decisions. If planning reveals a design gap, stop and update the SDD instead of hiding the decision here.

### PRD Summary

- Source: `docs/work-items/{work_item_id}/prd.md`
- Goals covered:
- Non-goals to protect:
- Acceptance criteria:

### SDD Summary

- Source: `docs/work-items/{work_item_id}/sdd.md`
- Design decisions to implement:
- Interfaces/contracts to preserve:
- Migration/compatibility requirements:

### ADR Summary

- ADRs: []
- Design rules that affect implementation:

## Slices

Use thin vertical slices where possible. Each slice should leave the repo in a reviewable state and include its own verification.

| Slice | Outcome | Files/modules | Documentation impact | Tests/checks | Dependencies | Review load |
| --- | --- | --- | --- | --- | --- | --- |
| 1.  |  |  | Updated / Not needed with reason / Blocked question |  |  | Low/Medium/High; expected file groups and risk |

Slice quality bar:

- Each slice names externally visible behavior or a concrete enabling outcome.
- Dependencies are explicit.
- Documentation impact is explicit: updated, not needed with reason, or blocked.
- Tests/checks are close to the changed behavior.
- Review load is estimated; slices expected to create overloaded PRs are split before decomposition.
- No planned slice should knowingly approach or exceed 200 changed files without an explicit human-approved exception.
- No slice exists only to "clean up" unless the SDD makes that cleanup necessary.

## Acceptance Criteria Traceability

Map PRD acceptance criteria to slices and verification.

| Acceptance criterion | Slice(s) | Verification |
| --- | --- | --- |
|  |  |  |

## Files / Modules

List expected touch points. This is a planning aid, not permission to ignore discovered code reality.

| File/module | Expected change | Reason |
| --- | --- | --- |
|  |  |  |

If implementation discovers different touch points, explain the variance in the implementation PR body.

## Documentation Impact

List expected documentation touch points. If no documentation update is expected, state the reason.

| Slice | Documentation path or surface | Expected change | Reason |
| --- | --- | --- | --- |
|  |  |  |  |

If implementation discovers different documentation impact, explain the variance in the implementation evidence.

## Test Strategy

Describe the minimum credible test set before coding starts.

- Unit tests:
- Integration/contract tests:
- Regression tests:
- Manual checks:
- Not testing, with reason:

Quality bar: tests prove behavior and contract conformance, not internal line-by-line implementation.

## Review Checklist

- [ ] The plan only implements the approved PRD and SDD.
- [ ] Every PRD acceptance criterion maps to at least one slice and verification.
- [ ] Every SDD interface/contract change appears in a slice.
- [ ] Every slice records documentation impact as updated, not needed with reason, or blocked.
- [ ] Migration, compatibility, observability, and security/privacy work is included or explicitly not needed.
- [ ] Slice order is dependency-safe and reviewable.
- [ ] Any newly discovered architecture decision has been moved back to the SDD/ADR process.
