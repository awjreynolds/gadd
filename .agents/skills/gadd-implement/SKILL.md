---
name: gadd-implement
description: Run /gadd:implement to execute one ready GADD Work Item or every ready Work Item under an approved boundary, with built-in Test-Driven Development. Use when the user says /gadd:implement, /gadd:implement <work-item-id>, or /gadd:implement ALL, asks to build, code, test, or ship the next approved Work Item, asks to implement an approved plan slice or vertical slice, or asks to work the child Work Items created by /gadd:decompose. Phrasings to recognize include "build the next approved Work Item", "code and test the ready slice", "implement everything that is ready", and "work the decomposed children". This is the Software Engineering lane gate after /gadd:approve and /gadd:decompose; it hands off to /gadd:verify <work-item-id> and does not close or archive Work Items.
---

# /gadd:implement

Execute one ready Work Item, or every ready Work Item under an approved boundary.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Input

```text
/gadd:implement <work-item-id>
/gadd:implement ALL
```

The `<work-item-id>` form selects exactly that Work Item. The `ALL` form selects every ready Work Item under the current approved boundary and implements them in dependency-safe order. If neither form is provided, stop and ask which target the user wants.

## Reads

- Work Item ledger
- parent Work Item ledger when the target is a child Work Item
- approved triage outcome, PRD, SDD, and/or `plan.md` as required by Work Item type

## Input Quality Gate

Required input standard before implementation:

- a ready Work Item that is not blocked by unfinished dependencies
- readable Work Item body and ledger
- approved boundaries required by Work Item type
- done criteria, acceptance criteria, or plan slice specific enough to implement and test
- documentation impact expectation from the Work Item, triage outcome, or parent plan, or enough context to record `updated`, `not_needed`, or `blocked`

Required inputs by Work Item type:

- `bug_fix`: approved triage outcome, GitNexus or approved fallback evidence, done criteria, documentation impact.
- `task`: approved triage outcome, GitNexus or approved fallback evidence, done criteria, documentation impact.
- `engineering_change`: `triage.approved_outcome.status: approved`, approved SDD, and `artifacts.sdd.implementation_route: single` for direct implementation or an optional approved plan when the SDD requires one.
- `product_requirement`: approved PRD, approved SDD, approved plan, and ready decomposed Work Item slice when decomposition exists.

If inputs fail this standard, do not edit product code or package artifacts. The earliest GADD command that can repair missing child work is `/gadd:decompose`; missing or wrong plan/design/product boundaries route to `/gadd:plan`, `/gadd:design`, `/gadd:refine`, `/gadd:scope`, or `/gadd:research` depending on the gap.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- `ALL` selects every ready Work Item and implements them in dependency-safe order; a Work Item ID selects exactly that Work Item.
- Follow the approved Work Item and parent plan when present, and preserve approved PRD, SDD, and plan boundaries. Do not silently update `plan.md` from implementation.
- Do not auto-decompose. For `product_requirement` or planned `engineering_change` work that depends on decomposed slices, report that there are no child Work Items to implement when no ready child Work Items exist. For `bug_fix`, `task`, or a single-slice `engineering_change` routed directly to implementation, implement the target Work Item itself. If the plan is approved but decomposition-dependent child Work Items do not exist, report that `/gadd:decompose` is required.
- If the plan is wrong, stop and return to the earliest affected `/gadd:design` or `/gadd:plan` step.
- The implementation PR contains product code, tests, and documentation updates required by the Work Item. Do not write `progress.md`.
- Run configured checks before PR.
- Account for documentation impact before marking implementation complete. The only valid documentation statuses are `updated`, `not_needed`, and `blocked`.
- If documentation impact is `updated`, record the changed documentation paths in implementation evidence. If documentation impact is `not_needed`, record the direct rationale. If documentation impact is `blocked`, do not mark implementation completed; report the blocking documentation question and the earliest command or human decision that can repair it.
- Update relevant documentation when the Work Item changes user-facing behavior, command behavior, public APIs, configuration, setup flow, templates, integration contracts, or operational workflow.
- Use the implementation PR body template to summarize plan adherence, tests/checks, and any approved deviations.
- In GitHub tracker mode, the implementation PR is a managed projection for review. Ask before creating or updating it, stop on external drift, and keep the Work Item ledger canonical.
- Record implementation completion evidence in the Work Item ledger, including changed-file summary, check evidence, documentation impact status and paths or rationale, and any implementation PR or local diff reference available.
- Mark the Work Item as implemented but not closed by setting `artifacts.implementation.status: completed`, `work_item.state: verification_required`, `closure.status: verification_required`, and `execution_context.next_command: /gadd:verify <work-item-id>` when those fields are available.
- If the ledger lacks verification or closure fields, record equivalent implementation completion evidence and state that `/gadd:verify <work-item-id>` is the next gate so `/gadd:next` can derive the same state.
- Do not archive Work Items.
- Do not close external Work Item projections.
- Do not mark Work Items done, archived, externally closed, or verified from this command; `/gadd:verify` decides closure readiness after implementation completion.
- Implementation PR reviewer prompt: "Does this implementation follow the approved plan?"

## Built-in TDD Loop

GADD is standalone. Run this loop directly from this skill; do not delegate it to another installed skill, command, or methodology package.

For each behavior in the Work Item:

1. Identify the next acceptance criterion or plan verification point.
2. Write the smallest focused test that proves the behavior is missing.
3. Run the focused test and confirm it fails for the expected reason.
4. Write the smallest implementation that makes the test pass.
5. Run the focused test and confirm it passes.
6. Update documentation for the behavior when required, or record why documentation is not needed.
7. Refactor only after the focused test is green.
8. Rerun the relevant broader test suite before moving to the next behavior.

If no test harness exists, create the smallest credible harness first. If a behavior cannot be tested automatically, state the reason and add the narrowest credible manual verification.

## Stop Conditions

- Work Item missing
- no ready Work Items exist
- decomposition-dependent plan is approved but `/gadd:decompose` has not created child Work Items
- plan is wrong
- tests/checks fail
- documentation impact is blocked
- implementation requires a product-scope change
