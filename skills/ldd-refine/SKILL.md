---
name: ldd-refine
description: Run /ldd:refine for an LDD ticket. Use when the user says /ldd:refine or wants to sharpen an LDD PRD for engineering handoff and review.
---

# /ldd:refine

Polish `prd.md` in the active draft or promoted ticket directory for the Product-to-engineering handoff, then use human approval as the gate that turns the draft into a real Product Requirement ticket.

## Owns

- Testable acceptance criteria
- Measurable success metrics
- Resolved or explicitly owned open questions
- Clear dependencies
- Removal of vague or solution-smuggling language

## Facilitation Protocol

Start by stating the boundary: `/ldd:refine` sharpens the Product-to-engineering handoff. It does not add product scope or technical design.

Support three entry modes when the user's intent is not already obvious:

- **Guided**: ask one handoff-quality question at a time.
- **Context dump**: use supplied context, skip resolved questions, and ask only for missing handoff decisions.
- **Best guess**: refine from available context, label assumptions, and keep uncertain points owned or explicitly non-blocking.

Core refinement questions:

1. Does every goal have acceptance coverage?
2. Does every user story have observable acceptance criteria?
3. Are success metrics measurable enough to judge release success?
4. Are dependencies clear and owned?
5. Are open questions resolved, owned, or explicitly non-blocking?
6. Does any language prescribe design or implementation mechanics?

## Bounded Shared Understanding Gate

Before committing refinement or asking for PRD approval, prove shared understanding of the handoff.

State the handoff understanding in this form:

> My understanding is that engineering design should solve [approved product outcomes], must not solve [non-goals], and will judge success by [acceptance/metrics]. The remaining questions are [resolved/owned/non-blocking]. Is this ready for engineering design?

Build an explicit coverage check before approval:

- For each goal, identify the covering user story, acceptance criteria, metric, and dependency or owner.
- For each acceptance criterion, confirm it is observable without prescribing design, implementation sequence, schemas, file placement, algorithms, or tests.
- If a goal is a discovery outcome, the acceptance criteria must name the concrete deliverable a maintainer will receive, not merely say the gap will be identified later.
- If coverage depends on human product knowledge, ask one direct question with a recommended answer.
- If refinement reveals missing product detail, route back to `/ldd:elaborate`.
- If refinement reveals changed goals or non-goals, route back to `/ldd:scope`.

Do not approve a PRD whose goals are covered only by circular statements, such as "identify the gaps" paired only with "a maintainer can identify the gaps." Require the artifact to specify the kind of gap inventory, decision, or observable output the user will receive.

When refinement is blocked, ask one decisive handoff question and include a recommended product-facing answer. If interrupted, answer the interruption, restate refinement status, and resume the current question.

## Product Quality Bar

- Every goal has acceptance coverage or an explicit reason it does not.
- Every user story is covered by acceptance criteria.
- Acceptance criteria are observable without prescribing design, implementation sequence, schemas, file placement, algorithms, or tests.
- Success metrics include a target, direction, threshold, or measurement owner.
- Dependencies name owner or status where possible.
- Open questions are resolved, owned, or explicitly non-blocking.
- The PRD has passed the bounded shared-understanding gate for engineering handoff.
- Anti-patterns to reject: vague acceptance criteria, unmeasurable metrics, ownerless open questions, solution-smuggling, and new product scope.

## Exit Gate

End with:

- artifact updated,
- expected ledger transition or event,
- remaining non-blocking questions,
- approval prompt,
- recommended next command after approval, usually `/ldd:design`.

Use this reviewer prompt exactly: "Is this ready for engineering design?"

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Product Manager command: do not read the codebase as a design input.
- If refinement changes the product meaning of an approved PRD, keep the stable ticket ID but mark the PRD artifact as draft, clear `approved_artifacts.prd`, keep or route `execution_context` to the PRD approval gate, record an approval-invalidated event, and require fresh human approval before `/ldd:design`.
- Use the PRD template's quality bar and handoff checklist before proposing a PRD PR.
- Do not expand scope or add technical design.
- Preserve the Product Manager boundary: acceptance criteria describe required product/workflow outcomes, not the engineering solution that will satisfy them.
- Commit locally after refinement.
- End refinement with an explicit approval prompt: `Reply approve PRD to promote the committed PRD to a stable ticket and create or sync the external Product Requirement ticket when a tracker is configured.`
- If the human has already approved the refined PRD in the current turn, do not stop at a refined draft. Promote it immediately.
- Promotion assigns the stable ticket ID, moves the draft directory out of `_drafts`, updates `ledger.yml` and PRD frontmatter links/IDs, marks the PRD approved, and commits the promotion.
- In `local` tracker mode, the promoted repo-local ledger directory is the real Product Requirement ticket.
- In an external tracker mode, promotion creates or binds the external Product Requirement ticket and records its ID/URL in `ledger.yml`.
- External Product Requirement tickets must be readable without opening the repo. Use `.ldd/templates/issue-body-prd.md` and include the PRD problem, goals, non-goals, users, user stories, acceptance criteria, success metrics, dependencies, open questions, and LDD links.
- Before updating an existing external ticket, re-read it. If its body changed since the last recorded sync hash or timestamp, stop and ask the human to reconcile the external contribution.
- PRD PR reviewer prompt: "Is this ready for engineering design?"

## Stop Conditions

- missing elaborated PRD
- acceptance criteria cannot be made testable
- open questions lack owner or resolution
- refinement reveals a scope problem, which returns to `/ldd:scope`
