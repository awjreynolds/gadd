---
ticket: null
draft_id: "2026-05-13-tracker-readiness-guided-next"
title: "Make LDD ready for external trackers and guided next actions"
created: 2026-05-13
updated: 2026-05-13
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

- Identify the functional gaps that prevent a maintainer from using LDD as the normal workflow for real project work.
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

## Users / Personas

- Maintainer dogfooding LDD - needs to know what is still missing before LDD can be trusted for day-to-day project work.
- Product or engineering lead using an external tracker - needs LDD work to remain visible in their team's existing planning and review surface without losing the repo-local source of truth.
- Contributor or implementation agent - needs the next LDD action to be explicit and actionable after workflow state has been diagnosed.
- Reviewer working in GitHub, Linear, or Jira - needs enough external context to review, discuss, and track LDD work without becoming responsible for LDD's canonical state.

## User Stories

1. As a maintainer dogfooding LDD, I want a clear assessment of the functional gaps that block normal use, so that I can prioritize the next product work instead of guessing from implementation details.
2. As a product or engineering lead using GitHub, I want the first tracker path to make LDD work visible in the same place as code review, so that adopting LDD does not hide work from existing planning and review routines.
3. As a reviewer in an external tracker, I want LDD-created work to show the product intent, current phase, and review status, so that I can participate without reading the full local ledger first.
4. As a maintainer, I want LDD to distinguish required tracker behavior from optional enhancement, so that GitHub, Linear, and Jira support can ship incrementally without weakening the common workflow.
5. As a contributor or implementation agent, I want `/ldd:next` to offer to continue with the next appropriate action, so that I can move from workflow diagnosis to execution with less manual command stitching.
6. As a maintainer, I want LDD to ask before durable local or external changes, so that helpful continuation does not become surprising automation.

## Acceptance Criteria

- [ ] A maintainer can identify the user-visible gaps that prevent LDD from being used as a normal project workflow with external tracker participation.
- [ ] LDD distinguishes mandatory tracker capabilities from optional tracker enhancements.
- [ ] GitHub, Linear, and Jira are treated as external collaboration surfaces while the repo-local ledger remains the canonical workflow record.
- [ ] GitHub is the first external-tracker dogfooding path.
- [ ] A user can understand which tracker path is ready for use, which is partially supported, and which is not yet supported.
- [ ] External tracker participation preserves LDD phase boundaries, including product scope, design, planning, implementation, verification, and closure.
- [ ] External tracker mutations require explicit human confirmation.
- [ ] `/ldd:next` reports the next LDD action and offers to continue when the next action is available and not blocked by unresolved drift or a missing human decision.
- [ ] `/ldd:next` does not perform durable local changes or external tracker changes without explicit human approval.
- [ ] When the next action is blocked, `/ldd:next` states the blocking reason and the human decision needed instead of offering unsafe continuation.

```gherkin
Scenario: Maintainer assesses whether LDD is usable with their tracker
  Given a maintainer wants to use LDD for real project work
  When they review LDD's tracker readiness
  Then they can see the required capabilities, optional enhancements, and unsupported tracker gaps
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
Scenario: Blocked next action is not automated
  Given the next workflow action requires a human decision or external mutation
  When a maintainer runs `/ldd:next`
  Then LDD states the blocking decision or confirmation needed
  And does not perform the action automatically
```

## Success Metrics

- A maintainer can classify LDD's functional gaps into required-for-use and optional-enhancement categories without reading implementation files.
- A reviewer can understand an LDD item's product intent, current phase, and required review action from the external collaboration surface plus the linked local artifact context.
- The GitHub-first tracker path is clear enough for day-to-day dogfooding without requiring Linear and Jira to reach feature parity first.
- `/ldd:next` reduces manual workflow stitching by offering a safe continuation path when the next action is unblocked.
- No normal LDD workflow requires an external tracker to become the canonical source of phase state.

## Dependencies

- LDD must remain local-ledger-first; external trackers are review, collaboration, and notification surfaces unless a later approved requirement explicitly changes that boundary.
- GitHub, Linear, and Jira have different workflow concepts, permission models, and API limits, so scope must allow a common LDD product model without assuming identical tracker behavior.
- GitHub is the first external-tracker dogfooding path; Linear and Jira remain follow-on collaboration surfaces.
- External tracker changes require human confirmation.
- `/ldd:next` must continue to diagnose workflow state accurately before it offers to continue with the next action.
- The functional-gap assessment should distinguish required MVP gaps from useful enhancements so the resulting work can be decomposed safely.

## Open Questions

- Resolved: the first external-tracker path should prioritize GitHub because it is closest to code review and repo-local workflow review.
- What is the minimum tracker behavior required for LDD to be considered "usable" rather than merely "sync-capable"?
- Should `/ldd:next` offer to run only the next LDD command, or should it also offer specific human-review actions such as approving an artifact, resolving drift, or choosing between blocked options? Owner: product refinement.
- What external-tracker information must be visible to reviewers versus available only through linked local artifacts? Owner: product refinement.
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
