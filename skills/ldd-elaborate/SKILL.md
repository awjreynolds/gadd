---
name: ldd-elaborate
description: Run /ldd:elaborate for an LDD ticket. Use when the user says /ldd:elaborate or wants to fill product detail inside existing LDD PRD scope.
---

# /ldd:elaborate

Update `prd.md` in the active draft or promoted ticket directory with product detail inside existing scope.

## Owns

- Problem
- Users / Personas
- User Stories
- Draft Acceptance Criteria
- Draft Success Metrics
- Open Questions

## Facilitation Protocol

Start by stating the boundary: `/ldd:elaborate` fills product detail inside existing scope. It preserves goals and non-goals. If product detail changes scope, stop and route back to `/ldd:scope`.

Support three entry modes when the user's intent is not already obvious:

- **Guided**: ask one product-detail question at a time.
- **Context dump**: use supplied context, skip resolved questions, and ask only for missing product detail.
- **Best guess**: draft product detail from available context, label assumptions, and keep uncertain points in open questions.

Core elaboration questions:

1. Who experiences the problem?
2. What are they trying to do?
3. What blocks them and why does it matter?
4. What user stories express the required outcomes?
5. What product-facing draft acceptance criteria prove the stories?
6. What draft metrics would indicate success?

When elaboration is blocked, ask one decisive question and include a recommended product-facing answer. If interrupted, answer the interruption, restate elaboration status, and resume the current question.

## Product Quality Bar

- Problem language is user-centered and specific.
- Personas are precise enough to guide acceptance.
- User stories describe user outcomes, not components or implementation steps.
- Draft acceptance criteria remain observable product/workflow outcomes.
- Draft metrics express product success, even if `/ldd:refine` must make them measurable later.
- Anti-patterns to reject: expanding goals/non-goals, solution-smuggling, generic "better UX" language, file paths, schemas, state machines, command algorithms, test strategy, and implementation sequence.

## Exit Gate

End with:

- artifact updated,
- expected ledger transition or event,
- unresolved product questions and owners,
- recommended next command, usually `/ldd:refine`,
- return path to `/ldd:scope` if goals or non-goals need change.

Use this decision language: "Elaboration ready. Continue to `/ldd:refine`, return to `/ldd:scope`, or stop?"

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Product Manager command: do not read the codebase as a design input.
- Use the PRD template as a quality contract. Preserve the scoped goals/non-goals and fill only product-detail sections.
- Do not expand scope. If elaboration exposes a scope problem, stop and recommend `/ldd:scope`.
- Keep acceptance criteria product-facing and draft-quality; testability is finalized by `/ldd:refine`.
- Draft acceptance criteria may name LDD workflow concepts, but should not prescribe exact command behavior, file names, schemas, state-machine transitions, algorithms, or verification mechanics unless the user explicitly made them part of the product requirement.
- If elaboration starts defining how the system should be implemented, capture that as a dependency, constraint, or open question for engineering design instead of acceptance criteria.
- Make a local commit after writing. Do not mutate GitHub unless explicitly approved for branch push/update.

## Stop Conditions

- missing scoped PRD
- elaboration would change goals or non-goals
- unresolved product question blocks useful detail
