---
ticket: LDD-0001
title: "Add LDD execution context and verification gate"
created: 2026-05-13
updated: 2026-05-13
status: approved
---

# PRD: Add LDD execution context and verification gate

<!--
Product Manager artifact. Describe the product need and acceptance boundary.
Do not use the codebase as design input. Do not include implementation choices,
architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets.
Capture technical uncertainty only as a dependency, constraint, or open question.
-->

## Problem

LDD now has a clear SDLC flow, rich external tickets, and standalone command-shaped skills, but downstream agents still lack a compact phase header that tells them what is approved, what context is authoritative, and what gate must be satisfied next.

Implementation closure is also underspecified. `/ldd:implement` can produce code and tests, but LDD does not yet have a separate closure gate that decides whether a child ticket is verified, ready to archive, and safe to close externally.

## Goals

- Define a compact LDD execution context/header that summarizes approved artifacts, phase state, boundaries, and the next gate for a ticket.
- Add an explicit verification gate after implementation and before archive/external close.
- Preserve LDD's existing separation between product scope, software design, planning, decomposition, implementation, and closure.
- Keep the feature agent-agnostic and standalone; it must not depend on external skills or a specific host agent.
- Make the workflow easier to resume, audit, and hand off across agents without requiring every phase to reread every artifact from scratch.

## Non-goals

- Do not build a general repository healthcheck.
- Do not add a full external tracker sync engine.
- Do not add multi-agent orchestration or swarm execution.
- Do not replace PRD, SDD, or plan artifacts with a single large state file.
- Do not make the SDD responsible for cross-phase workflow state.
- Do not introduce global ledger state outside per-ticket LDD artifacts.

## Users / Personas

- Product reviewer - needs confidence that product scope remains separate from design and implementation.
- Engineering reviewer - needs to see whether implementation matches the approved design and plan.
- Implementation agent - needs a compact handoff that identifies the approved context and the next gate.
- Maintainer - needs to resume LDD work without guessing which phase owns the next action.

## User Stories

1. As an implementation agent, I want a compact LDD context/header for the active ticket, so that I know which artifacts are approved, which boundaries apply, and what gate must be satisfied next.
2. As an engineering reviewer, I want implementation work to pass a dedicated LDD verification gate before closure, so that code is not treated as done until evidence is checked against the child ticket, PRD, SDD, and plan.
3. As a maintainer resuming work, I want workflow state and next action to be visible without reconstructing the whole history from conversation, so that I can continue the correct LDD phase safely.
4. As a product reviewer, I want verification to preserve product scope boundaries, so that implementation does not silently add scope or bypass the approved Product Requirement.
5. As an external tracker user, I want closure state to remain consistent with the repo-local ledger, so that external tickets do not appear complete before LDD verification has passed.

## Acceptance Criteria

- [ ] For an active ticket, LDD exposes compact context that lets an agent or maintainer identify the ticket's current phase, approved inputs, product/design/plan boundaries, and next required gate without relying on chat history.
- [ ] LDD treats implementation completion and ticket closure as separate workflow states.
- [ ] LDD provides a verification gate that reports whether child work is ready to mark done, archive, and close externally.
- [ ] LDD blocks closure when required evidence is missing, checks have not passed, scope/design drift is detected, or external ticket drift is unresolved.
- [ ] When implementation evidence exists but closure has not been approved, LDD indicates that verification is the next required gate.
- [ ] The verification gate is specific to LDD child-ticket closure and is not presented as a general repository healthcheck.
- [ ] The workflow remains local-ledger-first and does not require external skills, agent-specific orchestration, or a broad repository healthcheck.

```gherkin
Scenario: Implemented child work is not closed before verification
  Given a child work item has implementation evidence
  And closure has not been verified
  When a maintainer asks for the next LDD action
  Then LDD indicates that verification is required before archive or external close
```

```gherkin
Scenario: Verification blocks closure when evidence is incomplete
  Given a child work item is ready for closure review
  And required implementation evidence is missing or drift is unresolved
  When verification is performed
  Then LDD reports the blocking reason
  And the child work item remains unclosed
```

## Success Metrics

- A maintainer can identify the active ticket's current phase and next gate from LDD artifacts in under two minutes without relying on chat history.
- Child work is not archived or externally closed in the documented workflow until verification has passed or a human explicitly overrides the finding.
- Verification output is understandable to product and engineering reviewers without reading every source artifact end to end.
- Hostile tests cover attempted gate bypasses, including implementation without verification and closure with missing evidence.

## Dependencies

- LDD must remain repo-local-ledger-first.
- LDD skills must remain standalone and agent-agnostic.
- The context/header must be usable before, during, and after SDD creation, so it cannot be owned only by the SDD.
- Verification must be specific to child-ticket closure, not broad repository health.

## Open Questions

- Should the execution context be a separate per-ticket file or a section inside the existing ledger? Owner: engineering design.
- What minimum evidence is required before the verification gate can recommend closure? Owner: engineering design.
- Parent Product Requirement closure is out of scope for this MVP unless engineering design identifies a minimal roll-up state needed to support child-ticket verification.

## PRD Handoff Checklist

<!-- Complete before opening the PRD PR. -->

- [x] Problem is expressed from the user's perspective.
- [x] Goals and non-goals make the scope boundary clear.
- [x] User stories cover the main workflow and meaningful user-visible edge cases.
- [x] Acceptance criteria are observable without reading code.
- [x] Metrics define how product success will be judged.
- [x] Dependencies and open questions are explicit.
- [x] No implementation decisions, architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets are present.
