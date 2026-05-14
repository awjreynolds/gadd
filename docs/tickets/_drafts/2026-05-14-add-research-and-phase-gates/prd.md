---
ticket: 2026-05-14-add-research-and-phase-gates
title: "Add LDD research and phase input gates"
created: 2026-05-14
updated: 2026-05-14
---

# PRD: Add LDD research and phase input gates

<!--
Product Manager artifact. Describe the product need and acceptance boundary.
Do not use the codebase as design input. Do not include implementation choices,
architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets.
Capture technical uncertainty only as a dependency, constraint, or open question.
-->

## Problem

LDD can currently create plausible PRD drafts from thin context, but it does not have a first-class way to decide whether the source inputs are good enough before scoping starts. This creates two product risks for maintainers and product authors:

- weak or ambiguous input can be turned into confident-looking product scope;
- sensitive private context, including financial or commercial detail, can be mixed into repo or GitHub-visible artifacts without an explicit sanitization boundary.

The problem is sharper now that LDD is being configured for GitHub projection. External visibility is useful for review and collaboration, but only if LDD validates input quality, preserves repo-local canonical state, and keeps private PM intake material out of shareable artifacts.

## Goals

- Add a first-class LDD research phase that gathers PM-grade inputs before PRD scoping when the source context is weak, sensitive, or needs codebase investigation.
- Ensure the research phase can use full read-only visibility into the repository and relevant local context while recording findings as evidence, constraints, risks, assumptions, or open questions rather than product scope or design decisions.
- Add input-quality gates across LDD phases so each command validates that its approved or source inputs meet that phase's standard before producing or mutating its artifact.
- Strengthen `/ldd:scope` so it checks whether supplied inputs are good enough to define a useful product boundary, and routes to research or asks for missing source context when they are not.
- Preserve sensitive private PM inputs, including financially sensitive context, by allowing research to consume private/local context while committing only sanitized, shareable conclusions to repo and GitHub-visible artifacts.
- Use this Product Requirement to validate the configured GitHub projection path while preserving the repo-local ledger as canonical state.

## Non-goals

- Do not make GitHub the canonical source of LDD workflow state.
- Do not mutate GitHub from `/ldd:scope`; external tracker mutation remains gated by explicit human confirmation and the owning LDD command.
- Do not add Linear or Jira projection behavior as part of this Product Requirement.
- Do not store raw financially sensitive inputs, customer names, revenue figures, budgets, or private commercial notes in committed artifacts or GitHub-visible projections.
- Do not let research outputs prescribe architecture, command algorithms, file placement, schemas, implementation sequencing, or tests.
- Do not collapse research, scoping, elaboration, refinement, design, planning, implementation, and verification into a single monolithic command.

## Users / Personas

- LDD maintainer - needs each command to reject weak upstream inputs instead of silently inventing missing context.
- Product author - needs a guided way to gather standard PRD inputs before deciding product scope.
- Implementation agent - needs downstream artifacts that clearly identify which prior inputs were approved and which gaps must route backward.
- GitHub reviewer - needs enough shareable context to review LDD work without seeing private financial or commercial source material.

## User Stories

1. As an LDD maintainer, I want a research phase before scoping when inputs are weak or sensitive, so that PRD scope is based on explicit evidence rather than agent invention.
2. As a product author, I want research to prompt for standard PRD inputs, so that problem, users, evidence, current workflow, desired outcome, constraints, and open questions are gathered before scoping.
3. As a product author handling sensitive inputs, I want private PM context to remain outside committed and GitHub-visible artifacts, so that financial or commercial detail does not leak during LDD workflow projection.
4. As an LDD maintainer, I want each phase to validate its inputs before writing its artifact, so that bad upstream artifacts are rejected and routed to the earliest phase that can fix them.
5. As a GitHub reviewer, I want projected LDD artifacts to be sanitized and clearly tied back to repo-local canonical state, so that GitHub review validates integration without becoming the workflow source of truth.

## Acceptance Criteria

- [ ] A product author can start a research phase before scoping and receive prompts for source trigger, target users, problem evidence, current workflow, desired outcome, product importance, known constraints, prior context, comparable behavior, non-goal candidates, and open questions.
- [ ] A maintainer can run research with full read-only visibility into repository, documentation, existing LDD artifacts, and private/local context supplied by the human.
- [ ] The shareable research output separates product evidence, codebase facts, constraints, assumptions, risks, sensitivity handling, and open questions without turning findings into product scope or engineering design.
- [ ] Research readiness is reported as one of: ready for scope, blocked on more input, split recommended, or not a Product Requirement.
- [ ] Scope refuses to create or update goals and non-goals when source inputs do not identify a clear problem or desired product outcome.
- [ ] Scope routes weak inputs to research or asks for missing source context, instead of filling product boundaries from weak assumptions.
- [ ] Every LDD phase states the required input standard for that phase before writing or mutating its artifact.
- [ ] When a phase rejects its inputs, it names the blocking input gap and recommends the earliest LDD command that can fix the gap.
- [ ] Sensitive private inputs are consumed only as private intake material; committed artifacts and GitHub-visible projections contain sanitized conclusions and never raw financial or commercial details.
- [ ] GitHub projection validation creates or updates a shareable Product Requirement projection only after explicit human confirmation, and the projection states that the repo-local ledger remains canonical.

## Success Metrics

- Research readiness clarity: 100% of research outputs include one explicit readiness label and a recommended next LDD command or stop reason.
- Scope quality: 100% of scope runs either name the product boundary from adequate inputs or stop with a missing-input reason.
- Sensitivity protection: 0 raw financially sensitive values, customer names, budgets, revenue figures, or private commercial notes appear in committed or GitHub-visible artifacts produced by this workflow.
- Phase routing clarity: 100% of phase-gate rejections name the failing input standard and the earliest LDD command that can repair it.
- GitHub projection confidence: the first GitHub-visible Product Requirement projection for this work is readable without private source material and states that the repo-local ledger remains canonical.

## Dependencies

- The repository has GitHub projection configured, with repo-local ledgers remaining canonical.
- External GitHub mutations require explicit human confirmation and drift checks.
- `/ldd:research` needs a clear sensitivity boundary between private intake material and shareable repo/GitHub artifacts.
- Existing LDD command boundaries must be preserved: PM commands own product inputs and scope, design owns engineering translation, plan owns executable slices, implementation owns child work, verification and close own closure readiness and closure.
- Phase gates should reject poor inputs and route to the earliest phase that can fix them rather than silently inventing missing context.

## Open Questions

- Resolved: Research readiness labels are ready for scope, blocked on more input, split recommended, and not a Product Requirement.
- Resolved: Private research intake may come from project context, pasted notes, or human-supplied local private sources. Shareable artifacts must contain only sanitized conclusions.
- Resolved: GitHub validation for this Product Requirement should use the external Product Requirement issue projection after explicit human confirmation. Opening an additional PRD PR is optional follow-on behavior, not required for acceptance.
- Non-blocking, owner engineering design: Decide the implementation order for applying phase input gates across all LDD commands.

## PRD Handoff Checklist

<!-- Complete before opening the PRD PR. -->

- [x] Problem is expressed from the user's perspective.
- [x] Goals and non-goals make the scope boundary clear.
- [x] User stories cover the main workflow and meaningful user-visible edge cases.
- [x] Acceptance criteria are observable without reading code.
- [x] Metrics define how product success will be judged.
- [x] Dependencies and open questions are explicit.
- [x] No implementation decisions, architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets are present.
