---
name: gadd-elaborate
description: Run /gadd:elaborate for a GADD Product Requirement Work Item. Use when the user says /gadd:elaborate or wants to fill product detail inside existing GADD PRD scope.
---

# /gadd:elaborate

Update `prd.md` in the active draft or promoted Work Item directory with product detail inside existing scope.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

This is a Product Requirement lane command. It accepts direct PM-led product discovery or Work Items routed from triage with `state: needs_prd`. Reject `bug_fix`, `task`, and `engineering_change` Work Items with a clear route back to `/gadd:next <work-item-id>` or `/gadd:triage <work-item-id>`.

## Input

```text
/gadd:elaborate <work-item-id>
```

If no Work Item ID is provided, target the single active draft Work Item directory. If neither a Work Item ID nor an active draft exists, stop and route to `/gadd:scope` to create scope first. Do not infer a target from unrelated modified files.

## Owns

- Problem
- Users / Personas
- User Stories
- Draft Acceptance Criteria
- Draft Success Metrics
- Open Questions

## Facilitation Protocol

Start by stating the boundary: `/gadd:elaborate` fills product detail inside existing scope. It preserves goals and non-goals. If product detail changes scope, stop and route back to `/gadd:scope`.

Support three entry modes when the user's intent is not already obvious:

- **Guided**: ask one product-detail question at a time.
- **Context dump**: use supplied context, skip resolved questions, and ask only for missing product detail.
- **Best effort from supplied context**: draft product detail from available context, label explicit uncertainties, and keep uncertain points in open questions.

Core elaboration questions:

1. Who experiences the problem?
2. What are they trying to do?
3. What blocks them and why does it matter?
4. What user stories express the required outcomes?
5. What product-facing draft acceptance criteria prove the stories?
6. What draft metrics would indicate success?

## Input Quality Gate

Required input standard before writing product detail:

- an existing scoped PRD with goals, non-goals, and constraints
- enough user, workflow, problem, and desired-outcome context to map stories and product outcomes inside that scope
- no unresolved scope ambiguity that would change goals or non-goals

If inputs fail this standard, write nothing and name the blocking gap. The earliest GADD command that can repair missing product detail is `/gadd:elaborate`; missing or wrong scope routes to `/gadd:scope`; missing source evidence or weak PM inputs route to `/gadd:research`.

## Bounded Shared Understanding Gate

Before writing product detail or declaring elaboration ready, reach shared understanding of the product detail inside the existing scope.

This is a bounded shared understanding gate, not open-ended feature discovery. Ask enough to understand the user's intended problem, personas, and outcomes inside the approved scope; do not grow the scope to absorb every related idea.

State the understanding in this form:

> My understanding is that [personas] need [outcomes] because [problem/blocker]. The required product outcomes are [stories/observable results], within the existing goals and non-goals. Is that right?

Then walk each scoped goal one at a time:

- Explain what product fact would prove the goal is satisfied.
- Map the goal to at least one persona, user story, draft acceptance criterion, and draft metric, or explain why the goal is only a discovery outcome.
- If the answer depends on human product knowledge, ask one direct question with a recommended product-facing answer.
- If the branch exposes a new goal, new non-goal, or changed boundary, stop and route back to `/gadd:scope`.
- If the branch belongs to engineering design, planning, implementation, or verification, capture it as a dependency or open question for the owning phase instead of adding it to acceptance criteria.

Do not let best-effort mode resolve maintainer-specific knowledge silently. Label explicit uncertainties and ask unless the missing detail is clearly non-blocking.

When elaboration is blocked, ask one decisive question and include a recommended product-facing answer. If interrupted, answer the interruption, restate elaboration status, and resume the current question.

## Product Quality Bar

- Problem language is user-centered and specific.
- Personas are precise enough to guide acceptance.
- User stories describe user outcomes, not components or implementation steps.
- Draft acceptance criteria remain observable product/workflow outcomes.
- Draft metrics express product success, even if `/gadd:refine` must make them measurable later.
- Every scoped goal has visible product-detail coverage or an explicit blocking/non-blocking decision.
- Anti-patterns to reject: expanding goals/non-goals, solution-smuggling, generic "better UX" language, file paths, schemas, state machines, command algorithms, test strategy, and implementation sequence.

## Exit Gate

End with:

- artifact updated,
- expected ledger transition or event,
- unresolved product questions and owners,
- recommended next command, usually `/gadd:refine`,
- return path to `/gadd:scope` if goals or non-goals need change.

Use this decision language: "Elaboration ready. Continue to `/gadd:refine`, return to `/gadd:scope`, or stop?"

After writing elaboration, set `execution_context.phase: elaborate`, `execution_context.current_gate: elaborate`, `execution_context.next_command: /gadd:refine`, and `execution_context.next_human_action: null` when those fields are available. Do not set `current_gate: prd_approval`; PRD approval is owned by `/gadd:refine`.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Product Manager command: do not read the codebase as a design input.
- If elaboration changes the product meaning of an approved PRD, keep the stable Work Item ID but mark the PRD artifact as draft, clear `approved_artifacts.prd`, route `execution_context` back to `/gadd:refine`, record an approval-invalidated event, and require human approval before `/gadd:design`.
- Use the PRD template as a quality contract. Preserve the scoped goals/non-goals and fill only product-detail sections.
- Do not expand scope. If elaboration exposes a scope problem, stop and recommend `/gadd:scope`.
- Keep acceptance criteria product-facing and draft-quality; testability is finalized by `/gadd:refine`.
- Draft acceptance criteria may name GADD workflow concepts, but should not prescribe exact command behavior, file names, schemas, state-machine transitions, algorithms, or verification mechanics unless the user explicitly made them part of the product requirement.
- If elaboration starts defining how the system should be implemented, capture that as a dependency, constraint, or open question for engineering design instead of acceptance criteria.
- Make a local commit after writing. Do not mutate GitHub unless explicitly approved for branch push/update.

## Stop Conditions

- missing scoped PRD
- elaboration would change goals or non-goals
- unresolved product question blocks useful detail
- scoped goals or non-goals missing
- no covering acceptance signal draftable for a scoped goal
- supplied content describes architecture or file paths the user refuses to capture as constraints, dependencies, or open questions
