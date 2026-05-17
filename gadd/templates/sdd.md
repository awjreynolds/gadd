---
work_item: {work_item_id}
prd: gadd/work-items/{work_item_id}/prd.md
created: {date}
updated: {date}
adrs: []
---

# Software Design Document: {title}

## GADD Traceability

- Work Item: `{work_item_id}`
- Work Item type: `{work_item_type}`
- Local ledger: `gadd/work-items/{work_item_id}/ledger.yml`

## Structure

Summarize the design shape before the detailed sections. This is the human-readable header file for the SDD: concise, concrete, and synchronized with the detailed design below.

- Design intent:
- Primary components / modules:
- Responsibility boundaries:
- Key interfaces / contracts:
- Data or control flow:
- Explicit non-changes:
- Detail map:

Quality bar: a reviewer can read this section first and understand what is changing, which system parts are involved, which boundaries and interfaces matter, what is deliberately not changing, and where to read the detailed rationale.

## Context

Write the engineering context after the PRD is merged. Use the merged PRD, current code, and relevant ADRs as inputs.

- PRD: `gadd/work-items/{work_item_id}/prd.md`
- Existing entry points:
- Relevant ADRs:
- Terms from the codebase/domain glossary:

Quality bar: a reviewer can see what problem is being designed for, what existing system facts constrain it, and which PRD goals this design serves.

## Constraints

List hard constraints before proposing the design.

- Product constraints from the PRD:
- Technical constraints from existing code:
- Operational constraints:
- Compatibility constraints:
- Explicit non-goals:

Anti-patterns: do not smuggle in new product scope, do not restate the PRD as design, and do not treat a preferred implementation as a constraint unless the codebase or an ADR already makes it one.

## Existing System

Summarize the current implementation with enough detail to justify the design. Include file/module names when useful, but keep this explanatory rather than a code tour.

- Current flow:
- Current data/contracts:
- Extension points:
- Fragile or risky areas:
- Prior art to follow:

## Decision Summary

Record the chosen design decisions. Each decision should have a reason and an input source.

| Decision | Rationale | Source |
| --- | --- | --- |
|  |  | PRD / code / ADR |

Quality bar: the table distinguishes decisions from observations. If a decision changes architecture, add or link an ADR.

## Implementation Route

Choose the route that this SDD approval should enable.

- Route: `single` | `plan_required`
- Rationale:
- Review-load notes:

Quality bar: use `single` only when the approved design can be implemented as one direct Work Item without plan/decompose. Use `plan_required` when multiple reviewable slices, sequencing, dependency management, or review-load control are needed.

## Alternatives Considered

List credible alternatives, not strawmen.

| Alternative | Why not | Tradeoff accepted |
| --- | --- | --- |
|  |  |  |

## Proposed Design

Describe the design in stable engineering terms: modules, responsibilities, state, boundaries, and failure behavior. Prefer small named components with clear ownership over vague "update the system" prose.

- New or changed responsibilities:
- State/data changes:
- Boundary changes:
- Error handling:
- Backwards compatibility:

Quality bar: the implementation plan can be derived from this section without inventing architecture.

## Data Flow / Control Flow

Show the main path and important edge paths. Use bullets, numbered steps, or Mermaid if useful.

1. Main path:
2. Edge path:
3. Failure path:

Include where validation, persistence, retries, and user-visible outcomes happen.

## Interfaces / Contracts

Document public contracts the implementation must preserve or introduce.

| Contract | Producer | Consumer | Compatibility notes |
| --- | --- | --- | --- |
|  |  |  |  |

Include API shapes, CLI behavior, event payloads, database/schema changes, config keys, and file formats when applicable.

## Migration / Compatibility

State how existing users/data/config continue to work.

- Migration required:
- Rollout/backout:
- Default behavior:
- Compatibility tests:

## Observability

Define how success and failure will be visible after implementation.

- Logs:
- Metrics:
- Alerts:
- Debugging affordances:

## Security / Privacy

Call out security and privacy implications. Write "No new implications identified" only after checking inputs, storage, permissions, and data exposure.

- Data touched:
- Permissions/authz:
- Secrets:
- Abuse cases:

## ADRs

Link ADRs that already govern the design or are introduced by this change.

- Existing:
- New:

ADR threshold: create an ADR when the design changes a durable architectural rule, data ownership boundary, public contract, or cross-cutting convention. Do not create ADRs for routine implementation details.

## Open Design Questions

Open questions block planning if they affect architecture, contracts, data shape, or acceptance criteria. Assign an owner and the next action.

| Question | Impact | Owner | Next action |
| --- | --- | --- | --- |
|  |  |  |  |

## Review Checklist

- [ ] Every material PRD goal has a corresponding design decision or explicit non-design note.
- [ ] The design is grounded in current code and relevant ADRs.
- [ ] No product scope has been added beyond the PRD.
- [ ] New architectural decisions have ADRs or are clearly below the ADR threshold.
- [ ] Interfaces, migration, observability, and security/privacy have been considered.
- [ ] Open questions are either resolved or explicitly block plan approval.
