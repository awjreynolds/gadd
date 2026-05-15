# Work Item Triage Design

**Date:** 2026-05-16
**Status:** approved design
**Context:** extending GADD beyond PRD-first delivery so engineers and PMs can handle bugs, tasks, external issues, SDD-only engineering changes, and product requirements through one governed model.

## Summary

GADD should introduce **Work Item** as its canonical unit of governed work and add `/gadd:triage` as the front door for unclassified intake.

The current PRD-led workflow assumes work starts as a Product Requirement. That is too narrow for engineering reality: bugs, small tasks, externally raised issues, and technical changes often arrive before anyone knows whether they need direct implementation, an SDD, or a PRD. GADD needs a triage path that normalizes poor-quality intake, gathers evidence, uses GitNexus for blast-radius analysis, and routes work to the right downstream command.

`/gadd:triage` is not mandatory ceremony for PMs who already intend to develop a PRD. Known product discovery can still start with `/gadd:research` or `/gadd:scope`. Triage handles unclassified incoming work: external issues, bug reports, engineer tasks, support reports, ambiguous requests, and "what should we do with this?" items.

## Goals

- Replace GADD's canonical "Ticket" language with **Work Item** across the model.
- Add `/gadd:triage` as the intake and routing command for unclassified work.
- Normalize weak external issues into a local Triage Brief before routing or external mutation.
- Route Work Items to direct implementation, SDD-only design, PRD discovery, or terminal states.
- Make GitNexus an expected GADD setup component and required triage evidence for code-impact routing unless a human approves fallback.
- Keep external issues and labels useful to engineers who do not use GADD.
- Keep brainstorming and grill-style clarification as internal facilitation patterns, not visible workflow switches.

## Non-Goals

- Do not require `/gadd:triage` before deliberate PM-led PRD discovery.
- Do not keep backward-compatible "Ticket" terminology as a first-class GADD concept. GADD is new enough for a clean model shift.
- Do not make external tracker state canonical.
- Do not silently rewrite, close, relabel, or otherwise mutate external issues.
- Do not allow triage to bypass verification and closure evidence.
- Do not make manual repo inspection silently equivalent to GitNexus-backed blast-radius evidence.

## Canonical Language

**Work Item**:
The canonical repo-local unit of GADD-governed work. A Work Item can represent a bug fix, task, engineering change, product requirement, intake record, or rejected/non-GADD item.

**External Issue**:
A tracker-native record in GitHub, Linear, Jira, or another external system. External issues can be sources or projections of Work Items, but they are not canonical GADD state.

**Triage Brief**:
The canonical normalized intake artifact written by `/gadd:triage`. It captures the cleaned-up problem statement, evidence, repro status, acceptance or done criteria, blast-radius notes, missing information, route, and external projection plan.

**Triage Quality Loop**:
The bounded clarification loop inside `/gadd:triage`. It improves poor-quality intake only until the Work Item can be routed responsibly.

Avoid using **Ticket** as GADD's internal term. Use "ticket" only when referring to external systems or common engineer language.

## Work Item Types

`bug_fix`:
Broken behavior against a clear expectation.

`task`:
Bounded work where the desired outcome is clear and blast radius is low enough for implementation from the Triage Brief. This is broad by design; maintenance is one example, not the whole category.

`engineering_change`:
Product intent is settled, but SDD is needed because architecture, contracts, data model, security/privacy behavior, cross-repo impact, or blast radius is meaningful.

`product_requirement`:
The PRD path is required because product outcome, users, acceptance criteria, non-goals, or scope needs product agreement.

`external_issue_intake`:
A temporary type while poor-quality external input is being normalized.

`not_gadd_work`:
Duplicate, out of scope, unsupported, or not actionable through GADD.

## Triage States

Each triaged Work Item has exactly one state:

- `needs_info`: missing evidence blocks responsible routing or implementation quality.
- `ready_for_implementation`: implementation can start from the Triage Brief; no PRD, SDD, or plan is required.
- `needs_sdd`: product intent is clear, but engineering design is required before implementation.
- `needs_prd`: product scope or acceptance criteria needs PRD discovery and approval.
- `blocked_on_human_decision`: GADD can frame the decision, but a human must choose.
- `duplicate`: points to an existing canonical Work Item or external issue.
- `out_of_scope`: not accepted for GADD-managed work.
- `not_gadd_work`: should be handled outside GADD.

## Routing Rules

`ready_for_implementation` routes to:

```text
/gadd:implement <work-item-id>
```

`needs_sdd` routes to:

```text
/gadd:design <work-item-id>
```

In this path, the approved boundary is the Triage Brief rather than a PRD. `/gadd:plan` and `/gadd:decompose` remain available when the SDD yields multiple reviewable slices. For small SDD-only changes, plan/decompose may be skipped only when the SDD explicitly approves a single implementation route.

`needs_prd` routes to one of:

```text
/gadd:research <work-item-id>
/gadd:scope <work-item-id>
```

The route depends on whether the input still needs PM-grade research before scope.

`needs_info` remains in:

```text
/gadd:triage <work-item-id>
```

Terminal states may lead to an external update, label, comment, or close only after human-in-the-loop approval and drift checks.

## Route Thresholds

Direct implementation is allowed only when:

- desired behavior or done criteria are clear,
- the Work Item is localized enough for one focused implementation,
- GitNexus evidence supports low blast radius, or a human explicitly approves lower-confidence manual fallback,
- no architecture, contract, data, security/privacy, or cross-repo decision is needed,
- documentation impact is known or explicitly not needed with a reason.

SDD is required when the work touches or could materially affect:

- architecture or responsibility boundaries,
- public or internal contracts,
- data model or migration behavior,
- security, privacy, permissions, or compliance behavior,
- cross-repo or cross-service interactions,
- meaningful blast radius or review-load risk.

PRD is required when the work depends on:

- unclear product behavior,
- user outcome or workflow changes,
- acceptance criteria that need product agreement,
- scope, non-goal, or priority decisions,
- stakeholder trade-offs.

## Triage Quality Loop

`/gadd:triage` should not visibly switch the user into brainstorming or grill-style skills. It should run its own bounded quality loop:

1. Read the incoming request, external issue, comments, labels, and existing GADD state.
2. Bind or create a local Work Item early.
3. For bugs, attempt reproduction or identify the exact missing repro evidence.
4. Use GitNexus where code reality matters.
5. Draft or update the Triage Brief.
6. Identify only gaps that block routing or implementation quality.
7. Ask focused questions one at a time, or propose a cleaned-up external issue rewrite.
8. Stop when the Work Item can route to implementation, SDD, PRD discovery, or a terminal state.

The loop should sharpen ambiguity and challenge weak assumptions, but it must stay bounded to the routing decision.

## Triage Brief

The Triage Brief should include:

- Work Item ID, type, state, and route.
- Source summary and external bindings.
- Problem or request summary.
- Expected and actual behavior for bugs.
- Repro status and evidence.
- Affected users, workflows, systems, or commands.
- Acceptance criteria or done criteria.
- Constraints and non-goals.
- GitNexus evidence: indexed repos, freshness, affected areas, likely entry points, call paths, dependency notes, and blast-radius rationale.
- Missing information and questions asked.
- Route rationale.
- External projection plan.

The Triage Brief is canonical. External issue rewrites are projections.

## Triage Brief Storage And Binding

The Triage Brief is stored in the local Work Item directory, not inside the external tracker as canonical state.

Recommended local shape:

```text
docs/work-items/<work-item-id>-<slug>/
  ledger.yml
  triage-brief.md
```

For external issue intake, the Work Item ledger records the binding:

```yaml
external:
  provider: github
  kind: issue
  id: "123"
  url: "https://github.com/org/repo/issues/123"
  title: "Original external issue title"
  last_read_at: "2026-05-16T12:00:00Z"
  external_updated_at: "2026-05-16T11:58:00Z"
  body_hash: "sha256:..."
  labels:
    observed:
      - bug
      - gadd:needs-info
    managed:
      - gadd:needs-info
```

The Triage Brief records a human-readable source block that points back to the external issue and states whether the external body has been projected from the brief.

External tracker projection may add either a compact traceability block or an approved sanitized triage comment.

A compact GADD traceability block can be added to the issue body or comment:

```text
## GADD Traceability

- Work Item: GADD-123
- Local brief: docs/work-items/GADD-123-slug/triage-brief.md
- State: needs_sdd
- Last synchronized: 2026-05-16T12:00:00Z
```

That block is a pointer and sync marker, not the source of truth. The full Triage Brief remains local because it may contain repo evidence, GitNexus findings, lower-confidence fallback notes, or internal reasoning that should not automatically be copied to an external tracker.

A sanitized triage comment is appropriate when the external issue needs reporter questions, maintainer clarification, or a shareable summary of what GADD has established so far. It should be generated from the local Triage Brief, but it must not include raw private context, sensitive repo analysis, non-shareable GitNexus detail, or internal reasoning.

Recommended triage comment shape:

```text
## Triage Summary

What we have established:

- ...

What we still need:

- ...

Current GADD route:

- State: needs_info
- Likely route after clarification: needs_sdd | ready_for_implementation | needs_prd
```

For external issues raised by non-GADD users, the comment should be readable as normal engineering triage. GADD traceability should remain a small footer rather than the main content. Posting the comment, rewriting the body, applying labels, or closing the issue all require human approval and drift checks.

Before rewriting the external issue body or labels, `/gadd:triage` must re-read the external issue and compare the recorded `external_updated_at` and `body_hash`. If the issue changed since the last read, triage stops for human reconciliation instead of overwriting the reporter or another engineer.

## GitNexus Requirement

GADD should make GitNexus part of the expected setup.

`/gadd:setup` should provide GitNexus setup instructions, code-intelligence configuration, and indexing guidance for the current repository and related repositories.

`/gadd:triage` requires GitNexus evidence before routing `bug_fix`, `task`, or `engineering_change` Work Items to fast implementation or SDD-only design. Triage must know enough about affected entry points, likely file/module impact, dependencies, call paths, and related repositories before claiming low blast radius.

If GitNexus is unavailable, stale, or unindexed, triage must stop and route to setup or refresh unless a human explicitly approves manual fallback. Manual fallback must record lower confidence and cannot silently claim low blast radius. Product-only PRD scoping can proceed without GitNexus when code reality is not material.

This makes GitNexus required for normal impact-aware GADD usage while preserving a human-approved escape hatch for exceptional manual operation.

## External Tracker Projection

External tracker records are useful collaboration surfaces for engineers who may not use GADD.

When an external issue is poor quality, `/gadd:triage` should first write the local Triage Brief. It may then propose a rewritten external issue body, comment, labels, or close action. Any external mutation requires:

- human-in-the-loop approval,
- a fresh read of the external issue,
- drift detection against recorded sync metadata,
- a clear preview of the body, comments, labels, or close action.

External rewrites should be normal engineering-quality issue content first:

- concise summary,
- expected and actual behavior,
- reproduction or evidence,
- impact,
- acceptance or done criteria,
- constraints,
- known risks.

GADD traceability belongs in a small section at the bottom. It should not dominate the issue for non-GADD engineers.

Labels should be additive by default. Existing team labels remain unless the human explicitly approves removing or replacing them.

`/gadd:setup` should provide opinionated default label mappings with config overrides. Example labels:

- `gadd:needs-info`
- `gadd:ready-for-implementation`
- `gadd:needs-sdd`
- `gadd:needs-prd`
- `gadd:blocked-human`
- `type:bug`
- `type:task`
- `type:engineering-change`
- `type:product-requirement`

Labels are projection metadata, not canonical state. If external labels conflict with local state, GADD should detect drift and ask before overwriting.

## Workflow Documentation And Diagram

The public workflow documentation and generated workflow image must change with the triage model.

`README.md` currently presents one PRD-led SDLC flow. The new model needs a visible triage section that explains the two entry modes:

- known product discovery enters through `/gadd:research` or `/gadd:scope`,
- unclassified intake enters through `/gadd:triage`.

`docs/workflow.md` should add a dedicated triage section before the Product Requirement lane. That section should explain how triage normalizes weak intake, creates or binds a Work Item, writes the Triage Brief, uses GitNexus for blast-radius evidence, and routes to implementation, SDD, PRD discovery, or terminal states.

The workflow assets must be regenerated:

- `docs/assets/gadd-sdlc-workflow.svg`
- `docs/assets/gadd-sdlc-workflow.png`

The diagram should show triage as an intake/routing lane rather than forcing every Work Item through PRD. It should include at least these routes:

```text
Unclassified intake
  -> /gadd:triage
  -> Triage Brief
      -> ready_for_implementation -> /gadd:implement
      -> needs_sdd -> /gadd:design
      -> needs_prd -> /gadd:research or /gadd:scope
      -> needs_info / duplicate / out_of_scope / not_gadd_work

Known product discovery
  -> /gadd:research or /gadd:scope
  -> PRD lane
```

The PNG and SVG should remain generated documentation assets, not separate sources of truth. If the diagram is generated from a script or editable source during implementation, the source should be committed and validation should verify that the checked-in PNG/SVG are current.

## Downstream Command Changes

`/gadd:implement` should support Work Item types. For `bug_fix` and `task`, the approved boundary is the Triage Brief. Implementation still requires tests where practical, documentation impact, implementation evidence, and later `/gadd:verify` plus `/gadd:close`.

`/gadd:design` should support `engineering_change` Work Items whose approved boundary is the Triage Brief rather than a PRD. It still produces an SDD and records design evidence.

`/gadd:design` should support two approved boundary sources:

- an approved PRD for `product_requirement` Work Items,
- an approved Triage Brief for `engineering_change` Work Items.

It should not design directly from an unnormalized external issue. If the user passes an external issue reference, `/gadd:design` may resolve it only when it is already bound to a local Work Item with a design-ready state. Otherwise it must stop and route to `/gadd:triage <external-ref>` so triage can normalize the issue, gather GitNexus evidence, and decide whether the work needs SDD or PRD.

`/gadd:plan` and `/gadd:decompose` should remain available after SDD where multiple slices or review-load management are needed. They are not always required for small SDD-only engineering changes.

`/gadd:next` must understand Work Item states and route from triage outcomes, not only PRD-led ledgers.

`/gadd:verify` remains mandatory before closure, but its evidence checklist depends on Work Item type:

- fast-path `bug_fix` and `task`: Triage Brief plus implementation evidence,
- `engineering_change`: Triage Brief, SDD, optional plan/decomposition artifacts, plus implementation evidence,
- `product_requirement`: PRD, SDD, plan, decomposition artifacts, plus implementation evidence.

`/gadd:close` should close Work Items only after verification passes or an explicit human override is recorded.

## Impacted Skills

The triage model affects every command that currently assumes a PRD-led parent ticket, SDD, plan, or child-ticket hierarchy.

High-impact updates:

- `/gadd:setup`: must create `docs/work-items/`, Work Item templates, Triage Brief template, label mapping config, and GitNexus setup guidance. Setup should no longer describe `docs/tickets/` as canonical storage.
- `/gadd:next`: must navigate Work Item type/state/route. It must support direct implementation from `ready_for_implementation`, design from `needs_sdd`, PRD discovery from `needs_prd`, and terminal triage states.
- `/gadd:design`: must accept either an approved PRD or an approved Triage Brief as its design boundary. Raw external issues must route through triage first.
- `/gadd:approve`: must approve SDD gates that are attached to `engineering_change` Work Items without requiring an approved PRD. PRD approval remains required only for `product_requirement` Work Items.
- `/gadd:implement`: must choose its required inputs from Work Item type. `bug_fix` and `task` use the Triage Brief; `engineering_change` uses Triage Brief plus approved SDD and optional plan; `product_requirement` uses PRD, SDD, plan, and decomposition outputs.
- `/gadd:verify`: must verify Work Items, not only child tickets. Its required approved inputs depend on Work Item type.
- `/gadd:close`: must close verified Work Items and support external issue closure projections after human approval and drift checks.
- `/gadd:archive`: must archive closed Work Item packages under the configured Work Item archive directory.

Medium-impact updates:

- `/gadd:research`: remains a PM discovery command, but it must accept a Work Item routed from triage with `needs_prd`. It should not treat every Work Item as product work.
- `/gadd:scope`: remains product-scope-only, but it must create or update `product_requirement` Work Items rather than ticket directories. It can be entered directly by a PM or via triage.
- `/gadd:elaborate` and `/gadd:refine`: remain PRD-only commands and should reject `bug_fix`, `task`, and `engineering_change` Work Items with a clear route back to `/gadd:next` or `/gadd:triage`.
- `/gadd:plan`: must support `engineering_change` Work Items after SDD approval when plan/decompose is needed, while still requiring PRD plus SDD for `product_requirement` Work Items.
- `/gadd:decompose`: must support planned Work Item slices that are not necessarily children of a PRD issue. For `engineering_change`, child Work Items should attach to the SDD/design Work Item projection rather than a PRD projection.

Low-impact or wording updates:

- `/gadd:research`, `/gadd:scope`, `/gadd:elaborate`, and `/gadd:refine` should consistently describe themselves as the Product Requirement lane rather than the only GADD entry path.
- Public docs, workflow diagrams, templates, validation, and command adapters must replace user-facing "ticket" language with Work Item language except when referring to external tracker tickets/issues.

## Setup And Storage

Because GADD is new, the implementation should use a clean Work Item model rather than preserving `docs/tickets/` as canonical language.

Recommended storage:

```text
docs/work-items/
docs/work-items/_drafts/
docs/work-items/_archive/
```

Templates should use Work Item language:

```text
.gadd/templates/work-item-ledger.yml
.gadd/templates/triage-brief.md
.gadd/templates/prd.md
.gadd/templates/sdd.md
.gadd/templates/plan.md
.gadd/templates/verification.md
.gadd/templates/issue-body-work-item.md
.gadd/templates/issue-body-prd.md
.gadd/templates/issue-body-sdd.md
.gadd/templates/pr-body-implementation.md
```

These template names are the design target. When `/gadd:setup` copies `work-item-ledger.yml` into a Work Item directory, the local artifact should still be named `ledger.yml` so every Work Item has the same canonical machine-readable state file.

## Command Surface

Add:

```text
/gadd:triage [new|work-item-id|external-ref] [context]
```

Update design entry:

```text
/gadd:design <work-item-id>
/gadd:design <external-ref>
```

The external reference form is resolver-only. It can continue only if the external issue is already bound to a local Work Item whose state is `needs_sdd` or otherwise design-ready. Unbound or poor-quality external issues route back to `/gadd:triage`.

Keep direct PM entry points:

```text
/gadd:research [new|work-item-id] [context]
/gadd:scope [new|work-item-id] [context]
```

The distinction:

- `/gadd:triage` handles unclassified or externally raised intake.
- `/gadd:research` and `/gadd:scope` handle known product discovery.
- `/gadd:next` navigates existing Work Item state.

## Validation

Package validation should require:

- `/gadd:triage` skill and command adapters.
- Work Item language in public docs and templates.
- Triage Brief template.
- Work Item ledger schema.
- GitNexus setup guidance and config.
- Label mapping config.
- Updated `docs/assets/gadd-sdlc-workflow.svg` and `docs/assets/gadd-sdlc-workflow.png` showing triage and direct Work Item routing.
- A README/workflow triage section that distinguishes unclassified intake from known PM-led product discovery.
- Updated `/gadd:setup`, `/gadd:next`, `/gadd:approve`, `/gadd:implement`, `/gadd:design`, `/gadd:plan`, `/gadd:decompose`, `/gadd:verify`, `/gadd:close`, and `/gadd:archive` contracts.
- Product-lane commands that accept only `product_requirement` Work Items and reject other Work Item types cleanly.
- No remaining user-facing claim that a GADD Ticket is the canonical work unit.

## Open Implementation Decisions

- Exact ledger field names for Work Item type, state, route, external bindings, and GitNexus evidence.
- Whether SDD-only Work Items should have a separate approval gate or reuse `/gadd:approve` for SDD approval.
- Exact GitNexus freshness policy and how commands detect stale indexes.
- Exact external label defaults for GitHub and how Linear/Jira mappings should be represented.
- Whether storage migration from existing `docs/tickets/` examples is part of the first implementation plan or handled by regenerating examples.

These are implementation-plan decisions, not design blockers.
