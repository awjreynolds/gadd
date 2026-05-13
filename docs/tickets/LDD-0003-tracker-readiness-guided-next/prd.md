---
ticket: LDD-0003
title: "Make LDD ready for external trackers and guided next actions"
created: 2026-05-13
updated: 2026-05-13
status: draft
---

# PRD: Make LDD ready for external trackers and guided next actions

<!--
Product Manager artifact. Describe the product need and acceptance boundary.
Do not use the codebase as design input. Do not include implementation choices,
architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets.
Capture technical uncertainty only as a dependency, constraint, or open question.
-->

## Problem

LDD is becoming useful as a local, ledger-driven workflow, but it is not yet clear what is functionally missing before it can be used as the normal way to run real project work with external collaboration surfaces.

A maintainer can create and advance local LDD artifacts, but teams usually coordinate through GitHub, Linear, Jira, or a mix of those tools. Without a clear product boundary for tracker readiness, LDD risks becoming either too local to adopt in real workflows or too coupled to one tracker to remain portable.

There is also a handoff gap in `/ldd:next`. It can tell a maintainer what the next command is, but it does not yet help them continue from diagnosis into action. That leaves extra manual friction at exactly the moment LDD should make workflow state easy to resume.

## Goals

- Produce a functional gap inventory that names what prevents a maintainer from using LDD as the normal workflow for real project work, and classifies each gap as required-for-use or optional enhancement.
- Make LDD usable with external planning and review surfaces, especially GitHub, Linear, and Jira, while preserving the repo-local ledger as the canonical workflow record.
- Let a maintainer understand which tracker capabilities are required for basic LDD use, which are optional, and which should remain out of scope for the near term.
- Improve `/ldd:next` so it not only reports the next LDD command, but also offers to perform the next action when that action is appropriate for the current workflow state.
- Preserve human confirmation before any external tracker mutation or workflow transition that changes durable state.

## Non-goals

- Do not replace the repo-local ledger with GitHub, Linear, Jira, or any other external tracker.
- Do not require all three tracker integrations to be equally complete before LDD can become useful.
- Do not build a general project-management platform, bidirectional sync engine, or generic issue migration tool.
- Do not make `/ldd:next` perform external mutations or local artifact changes without an explicit human go-ahead.
- Do not collapse the existing LDD phases into a single automatic command that bypasses product, design, planning, implementation, verification, or closure gates.
- Do not make tracker-specific authentication, permissions, or hosting choices part of product scope unless they directly change the user-facing workflow boundary.
- Do not solve every functional gap identified by the inventory inside this PRD; follow-on gaps may become separate PRDs.

## Users / Personas

- Maintainer dogfooding LDD - needs to know what is still missing before LDD can be trusted for day-to-day project work.
- Product or engineering lead using an external tracker - needs LDD work to remain visible in their team's existing planning and review surface without losing the repo-local source of truth.
- Contributor or implementation agent - needs the next LDD action to be explicit and actionable after workflow state has been diagnosed.
- Reviewer working in GitHub, Linear, or Jira - needs enough external context to review, discuss, and track LDD work without becoming responsible for LDD's canonical state.

## Functional Gap Inventory

- Required for use: LDD needs a GitHub-first visibility path for PRDs, design and plan review, implementation PRs, and closure state. Without this, real work remains hidden from the place where code review and project discussion already happen.
- Required for use: `/ldd:next` needs to move beyond diagnosis by offering to continue with the next safe command or collect the required human decision. Without this, resuming LDD work still requires manual command stitching.
- Required for use: LDD PM commands need to prove shared understanding of the core product gap before treating a PRD as ready. Without this, agents can produce plausible artifacts that miss the maintainer's actual blocker.
- Optional enhancement: Linear and Jira should remain follow-on collaboration surfaces once the GitHub-first path proves the common tracker model.

## User Stories

1. As a maintainer dogfooding LDD, I want a clear assessment of the functional gaps that block normal use, so that I can prioritize the next product work instead of guessing from implementation details.
2. As a product or engineering lead using GitHub, I want the first tracker path to make LDD work visible in the same place as code review, so that adopting LDD does not hide work from existing planning and review routines.
3. As a reviewer in an external tracker, I want LDD-created work to show the product intent, current phase, and review status, so that I can participate without reading the full local ledger first.
4. As a maintainer, I want LDD to distinguish required tracker behavior from optional enhancement, so that GitHub, Linear, and Jira support can ship incrementally without weakening the common workflow.
5. As a contributor or implementation agent, I want `/ldd:next` to offer to continue with the next appropriate action, so that I can move from workflow diagnosis to execution with less manual command stitching.
6. As a maintainer, I want LDD to ask before durable local or external changes, so that helpful continuation does not become surprising automation.

## Acceptance Criteria

- [ ] The PRD includes a functional gap inventory that names the GitHub-first visibility path, `/ldd:next` safe continuation, and PM shared-understanding gate as required-for-use gaps.
- [ ] The functional gap inventory classifies Linear and Jira support as a follow-on optional enhancement until the GitHub-first tracker model is proven.
- [ ] Each listed functional gap explains why it blocks or does not block normal LDD use.
- [ ] LDD distinguishes mandatory tracker capabilities from optional tracker enhancements, with mandatory capabilities limited to work visibility, phase/status visibility, review participation, and safe handoff back to the canonical local workflow.
- [ ] GitHub is the first external-tracker dogfooding path, and Linear and Jira are clearly presented as follow-on collaboration surfaces.
- [ ] A maintainer can understand whether each tracker path is ready for use, partially supported, or not yet supported.
- [ ] GitHub-visible LDD work gives reviewers enough context to understand product intent, current LDD phase, required review or human action, and where canonical local context lives.
- [ ] External tracker participation preserves LDD phase boundaries, including product scope, design, planning, implementation, verification, and closure.
- [ ] External tracker mutations require explicit human confirmation.
- [ ] `/ldd:next` reports the next LDD action and offers to continue when the next command is available and not blocked by unresolved drift or a missing human decision.
- [ ] `/ldd:next` asks for the relevant human decision when the next step is artifact approval, drift resolution, external mutation confirmation, or a choice between blocked options.
- [ ] `/ldd:next` does not perform durable local changes or external tracker changes without explicit human approval.
- [ ] When the next action is blocked, `/ldd:next` states the blocking reason and the human decision needed instead of offering unsafe continuation.

```gherkin
Scenario: Maintainer assesses whether LDD is usable with their tracker
  Given a maintainer wants to use LDD for real project work
  When they review LDD's tracker readiness
  Then they can see the required-for-use gaps, optional enhancements, and which tracker is first for dogfooding
```

```gherkin
Scenario: External tracker does not replace local workflow truth
  Given LDD work is visible in an external tracker
  When a reviewer discusses or tracks that work externally
  Then the repo-local ledger remains the canonical record for LDD phase state and approvals
```

```gherkin
Scenario: Next action is offered after workflow diagnosis
  Given LDD can identify the next workflow action
  When a maintainer runs `/ldd:next`
  Then LDD reports the next action
  And asks whether to continue with that action when continuation is safe and appropriate
```

```gherkin
Scenario: Human review action is requested instead of automated
  Given the next workflow step is a product, design, plan, verification, or closure approval
  When a maintainer runs `/ldd:next`
  Then LDD asks for the required human decision
  And waits for confirmation before changing durable workflow state
```

```gherkin
Scenario: Blocked next action is not automated
  Given the next workflow action requires a human decision or external mutation
  When a maintainer runs `/ldd:next`
  Then LDD states the blocking decision or confirmation needed
  And does not perform the action automatically
```

## Success Metrics

- Maintainer gap classification: a maintainer can classify each identified gap as required-for-use or optional-enhancement from the PRD without reading implementation files.
- Reviewer comprehension: a reviewer can identify product intent, current LDD phase, required review action, and canonical local context from the GitHub-visible surface plus linked local artifact context.
- GitHub-first dogfooding readiness: the GitHub path is usable for day-to-day dogfooding before Linear or Jira feature parity is required.
- `/ldd:next` continuation quality: when the next workflow action is unblocked, `/ldd:next` offers either to run the next command or to collect the required human decision.
- Canonical-state protection: normal LDD workflow state remains understandable from repo-local artifacts even when external tracker surfaces are present.

## Dependencies

- Local-ledger-first workflow. Status: required product boundary. Owner: maintainer.
- GitHub-first external tracker dogfooding. Status: resolved product decision. Owner: maintainer.
- Linear and Jira follow-on compatibility. Status: non-blocking for GitHub-first delivery. Owner: future product refinement.
- Human confirmation for external tracker changes. Status: required product boundary. Owner: maintainer.
- Accurate `/ldd:next` state diagnosis before continuation offers. Status: required product boundary. Owner: engineering design.
- Functional-gap classification into required MVP gaps and optional enhancements. Status: required handoff outcome. Owner: engineering design.

## Open Questions

- Resolved: the first external-tracker path should prioritize GitHub because it is closest to code review and repo-local workflow review.
- Resolved: minimum usable tracker behavior means work visibility, phase/status visibility, review participation, and safe handoff back to the canonical local workflow. Broader bidirectional sync is optional.
- Resolved: `/ldd:next` should offer to run the next unblocked LDD command, and should ask for human-review decisions when the next step is approval, drift resolution, external mutation confirmation, or a blocked-option choice.
- Resolved: external tracker surfaces should show product intent, current LDD phase, required review or human action, and where canonical local context lives. Detailed artifacts may remain linked rather than fully duplicated when the tracker surface stays readable.
- Resolved: GitHub should be used for the first dogfooding path.

## PRD Handoff Checklist

<!-- Complete before opening the PRD PR. -->

- [x] Problem is expressed from the user's perspective.
- [x] Goals and non-goals make the scope boundary clear.
- [x] User stories cover the main workflow and meaningful user-visible edge cases.
- [x] Acceptance criteria are observable without reading code.
- [x] Metrics define how product success will be judged.
- [x] Dependencies and open questions are explicit.
- [x] No implementation decisions, architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets are present.
