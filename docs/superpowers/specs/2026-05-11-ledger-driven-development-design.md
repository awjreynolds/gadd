# Ledger-Driven Development — MVP Design

**Date:** 2026-05-11
**Status:** Superseded by `docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md`
**Author:** awjreynolds (with AI-assisted design review)

## 1. Thesis

Ledger-Driven Development (LDD) is an explicit, reviewable workflow for AI-assisted software work. It reduces cognitive overload by separating the hats people wear during delivery:

- **PM hat:** define and refine the product requirement.
- **SE hat:** turn the requirement into a software design and implementation plan.
- **Implementation hat:** execute the approved plan with code and tests.

The MVP validates the skills and handoff model, not backend portability or a complete methodology. GitHub is the ledger for the MVP. GitHub Issues and Pull Requests already provide stateful information; LDD must use that native functionality instead of inventing duplicate labels, gates, or audit ledgers.

### Audience and Positioning

LDD is for teams that already use GitHub Issues and Pull Requests as their coordination surface and want AI-assisted work to fit that review model. Its audience is not primarily solo-agent orchestration users; it is teams that need explicit PM-to-SE and SE-to-implementation handoffs, reviewable artifacts, and a clear source of truth for workflow state.

The MVP should therefore stay intentionally narrow:

- use GitHub-native issue and PR state as the ledger
- produce artifacts that make handoffs easier to review
- preserve separate PM, SE, and implementation responsibilities
- avoid local progress logs, task runners, or agent-session continuity systems as workflow state
- avoid multi-agent ceremony unless it directly improves one of the explicit handoffs

Adjacent systems such as QRSPI can inform prompt discipline, review habits, and phase naming, but they are not the architectural base for the MVP. LDD optimizes for organizational reviewability; QRSPI optimizes for agent orchestration and session continuity.

### Installable Skill Packaging

This repository is the source for installable LDD skills. The canonical source layout is `skills/<skill-name>/SKILL.md` with bundled resources under that skill's `assets/`, `references/`, or `scripts/` directories.

The MVP ships command-shaped skills rather than a user-facing shared core skill:

```text
skills/ldd-setup
skills/ldd-next
skills/ldd-scope
skills/ldd-elaborate
skills/ldd-refine
skills/ldd-design
skills/ldd-plan
skills/ldd-implement
```

Each command skill carries the small shared LDD invariant contract directly: GitHub is the ledger, GitHub mutations require human confirmation, and LDD must not create duplicate local workflow state. This keeps installation and invocation aligned with user intent; there is no separate `ldd-core` skill a user must understand before they can run `/ldd:*`.

Adapter-specific command files, such as Claude slash-command prompts, are generated or copied from bundled skill assets. They are not the source of truth for the workflow. The MVP may ship adapter assets to make installation useful, but the design must keep the installable skill folder as the canonical artifact.

## 2. MVP Scope

The MVP supports one direct GitHub issue at a time:

```text
GitHub issue
  -> PRD PR
  -> SDD/Plan PR
  -> Implementation PR
  -> issue closed
```

The MVP includes these commands:

```text
/ldd:setup
/ldd:next
/ldd:scope
/ldd:elaborate
/ldd:refine
/ldd:design
/ldd:plan
/ldd:implement
```

The MVP explicitly excludes:

- `/ldd:prepare`
- `/ldd:triage`
- `/ldd:repair`
- hotfix / retrofit paths
- epics, parent PRDs, decomposition, child ticket materialisation
- phase labels, gate labels, PR labels, and LDD-specific issue state labels
- JIRA, Linear, local-file ledgers, and backend abstraction work
- machine-readable audit event files
- automatic GitHub Actions for workflow state transitions

These can be added later if real usage shows the pain.

## 3. State Model

GitHub is the ledger. LDD reads state from GitHub-native objects:

- GitHub issue open / closed state
- linked PRs
- PR branch names
- PR titles and bodies
- PR draft / ready-for-review state
- PR review state
- PR checks
- PR merged / closed state

LDD does **not** create MVP labels for phases, gates, risk, type, PR state, or workflow state.

An issue number is the ticket ID. Paths and branches use the GitHub issue number directly:

```text
docs/tickets/123/prd.md
docs/tickets/123/sdd.md
docs/tickets/123/plan.md
docs/tickets/123/plan.html

ldd/prd/123
ldd/sdd-plan/123
ldd/impl/123
```

PRs identify themselves through branch, title, body, and issue reference:

```text
PRD branch:      ldd/prd/123
PRD title:       PRD: <issue title>
PRD body:        references #123

SDD/Plan branch: ldd/sdd-plan/123
SDD/Plan title:  SDD + Plan: <issue title>
SDD/Plan body:   references #123

Implementation branch: ldd/impl/123
Implementation title:  <issue title>
Implementation body:   closes #123
```

`/ldd:next` finds workflow state by reading the issue, linked PRs, and expected branch names. Local artifacts guide unfinished local work, but they do not override GitHub state.

## 4. Human Control

LDD skills may make local repo changes when explicitly invoked:

- create or switch to the appropriate `ldd/...` branch
- edit artifacts
- generate `plan.html`
- create local commits

GitHub mutations require human confirmation:

- pushing a branch
- opening or updating a PR
- commenting on an issue or PR
- requesting reviewers
- closing an issue

The command owns its natural endpoint. There is no separate `/ldd:publish` or `/ldd:submit`.

Examples:

```text
/ldd:refine
  -> commits refined prd.md locally
  -> summarizes output
  -> asks before pushing/opening/updating the PRD PR

/ldd:plan
  -> commits sdd.md, ADR changes, plan.md, and plan.html locally
  -> summarizes output
  -> asks before pushing/opening/updating the SDD/Plan PR

/ldd:implement
  -> commits code/tests locally
  -> runs checks
  -> summarizes output
  -> asks before pushing/opening/updating the Implementation PR
```

This follows the Pocock skill pattern: produce a recommendation or artifact, let the human review, then apply visible issue-tracker changes only after approval.

## 5. Workflow

### Requirements / Code Influence Boundary

LDD isolates product intent from implementation influence. It does not isolate software design from the existing codebase.

The PM hat (`/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`) owns what should be built and why. These commands may read the GitHub issue and any user-provided product context, but they should avoid codebase-driven solution shaping. If code knowledge appears during PM work, it can be captured only as a dependency, constraint, or open question; it must not silently rewrite goals, non-goals, user stories, or acceptance criteria.

The SE hat (`/ldd:design`, `/ldd:plan`) is where the existing system is allowed to shape the work. `/ldd:design` reads the merged PRD, relevant code, and ADRs to discover constraints, interfaces, migration risk, and architectural trade-offs. `/ldd:plan` reads the PRD, SDD, and ADRs and turns the approved design into implementation slices.

If code reality contradicts the PRD, the workflow returns to the earliest affected PM step. If planning discovers a missing architectural decision, it stops and returns to `/ldd:design`. The design and plan must not hide product-scope changes inside technical artifacts.

### 5.1 PM Hat: PRD PR

The PM hat produces `prd.md` on `ldd/prd/<issue>`.

```text
/ldd:scope
  -> writes scope boundaries
  -> local commit

/ldd:elaborate
  -> fills product detail
  -> local commit

/ldd:refine
  -> sharpens for engineering handoff
  -> local commit
  -> after human approval, opens/updates PRD PR
```

The PRD PR contains:

```text
docs/tickets/<issue>/prd.md
```

The PRD PR is reviewed as the PM-to-SE handoff. It answers: "Is this the right thing to build, and is it precise enough for engineering design?"

### 5.2 SE Hat: SDD/Plan PR

The SE hat produces `sdd.md`, `plan.md`, `plan.html`, and any necessary ADR changes on `ldd/sdd-plan/<issue>`.

```text
/ldd:design
  -> reads merged PRD
  -> researches codebase
  -> reads existing ADRs
  -> writes sdd.md
  -> creates or updates ADRs when necessary
  -> local commit

/ldd:plan
  -> turns SDD into implementation slices
  -> writes plan.md
  -> renders plan.html
  -> local commit
  -> after human approval, opens/updates SDD/Plan PR
```

The SDD/Plan PR contains:

```text
docs/tickets/<issue>/sdd.md
docs/tickets/<issue>/plan.md
docs/tickets/<issue>/plan.html
docs/adr/...                    # only when ADR threshold is met
```

The SDD/Plan PR is reviewed as the SE-to-implementation handoff. It answers:

- Does the software design satisfy the PRD?
- Are ADR updates justified?
- Does the implementation plan follow from the SDD?
- Is the plan specific enough for an AI implementation agent to execute?

### 5.3 Implementation Hat: Implementation PR

The implementation hat executes the merged plan on `ldd/impl/<issue>`.

```text
/ldd:implement
  -> reads merged PRD, SDD, ADRs, plan.md, and plan.html
  -> implements plan slices using TDD
  -> commits code/tests
  -> runs checks
  -> after human approval, opens/updates Implementation PR
```

The Implementation PR contains product code and tests. It should not write a `progress.md`; GitHub commits, PR body, review comments, and checks already provide implementation progress and verification state.

The Implementation PR title should be the feature title, not an LDD-specific title. The PR body links to the PRD, SDD, plan, plan HTML, and relevant ADRs.

If implementation discovers the plan is wrong, implementation stops. The workflow returns to the earliest affected explicit step:

- PRD assumption wrong -> rerun `/ldd:scope`, `/ldd:elaborate`, or `/ldd:refine` on the PRD branch.
- SDD decision wrong -> rerun `/ldd:design` on the SDD/Plan branch, then rerun `/ldd:plan`.
- Plan sequencing wrong -> rerun `/ldd:plan` on the SDD/Plan branch.

The plan is not silently amended during implementation.

## 6. Revision Rules

Revisions happen on the same review branch by rerunning the earliest affected phase and then rerunning downstream phases on that branch.

Examples:

```text
PRD PR review: acceptance criteria are vague
  -> rerun /ldd:refine
  -> new commit on ldd/prd/123
  -> same PRD PR updates

PRD PR review: scope is wrong
  -> rerun /ldd:scope
  -> rerun /ldd:elaborate
  -> rerun /ldd:refine
  -> same PRD PR updates

SDD/Plan PR review: design misses an architectural constraint
  -> rerun /ldd:design
  -> rerun /ldd:plan
  -> same SDD/Plan PR updates

Implementation finds plan cannot work
  -> stop implementation
  -> rerun /ldd:design or /ldd:plan as appropriate
  -> update SDD/Plan PR or open a fresh one if prior PR had already merged
```

Local commits per phase are intentional. They create rollback points and preserve explicit thinking steps without creating GitHub PR noise.

## 7. Command Semantics

### Command Contract Matrix

Every MVP command has a narrow contract. The command may do only the work in its row; if it discovers a problem owned by an earlier row, it stops and reports the earliest command that must be rerun.

| Command | Input | GitHub reads | Local reads | Local writes | Branch | Local commit | GitHub mutation after approval | Stop conditions |
|---|---|---|---|---|---|---|---|---|
| `/ldd:setup` | none | remote repository metadata, default branch | git remotes, repo root | `.ldd/config.yml`, `docs/tickets/`, templates | current branch | optional setup commit | none in MVP | no GitHub remote, `gh` unavailable, `gh` unauthenticated, default branch cannot be inferred |
| `/ldd:next <issue>` | issue number | issue state, linked PRs, PR branches, titles, bodies, reviews, checks, merge state | expected local branches and artifacts | none | none | no | none | issue not found, ambiguous linked PRs, local state conflicts with GitHub state |
| `/ldd:scope <issue>` | issue number | issue title/body/comments only as product context | existing `prd.md` if present | `docs/tickets/<issue>/prd.md` sections owned by scope | `ldd/prd/<issue>` | yes | optional branch push only | issue not found, non-product ambiguity requires human answer, requested change belongs to a later PM step |
| `/ldd:elaborate <issue>` | issue number | issue title/body/comments only as product context | scoped `prd.md` | `prd.md` sections owned by elaborate | `ldd/prd/<issue>` | yes | optional branch push only | missing scope, elaboration would expand scope, unresolved product question blocks useful detail |
| `/ldd:refine <issue>` | issue number | issue title/body/comments only as product context | elaborated `prd.md` | polished `prd.md` | `ldd/prd/<issue>` | yes | push/open/update PRD PR | missing elaboration, acceptance criteria cannot be made testable, open questions lack owner or resolution |
| `/ldd:design <issue>` | issue number | merged PRD PR, issue state, relevant PR links | merged `prd.md`, relevant code, ADR directory | `sdd.md`, ADR changes only when threshold is met | `ldd/sdd-plan/<issue>` | yes | optional branch push only | PRD PR not merged, code reality contradicts PRD, ADR-worthy decision cannot be resolved |
| `/ldd:plan <issue>` | issue number | merged PRD PR, SDD/Plan PR if present | merged `prd.md`, `sdd.md`, relevant ADRs | `plan.md`, generated `plan.html` | `ldd/sdd-plan/<issue>` | yes | push/open/update SDD/Plan PR | missing SDD, planning discovers new architecture decision, implementation slices cannot trace to acceptance criteria |
| `/ldd:implement <issue>` | issue number | merged PRD and SDD/Plan PRs, implementation PR if present | merged `prd.md`, `sdd.md`, ADRs, `plan.md`, `plan.html`, code/tests | product code and tests only | `ldd/impl/<issue>` | yes | push/open/update Implementation PR | PRD or SDD/Plan PR not merged, plan is wrong, tests/checks fail, implementation requires product-scope change |

PM-hat commands intentionally do not read the codebase as a design input. If a user supplies code facts during PM work, the command treats them as constraints or open questions, not as permission to smuggle a solution into the PRD.

Only `/ldd:next` is read-only. All other commands may make local changes when explicitly invoked, but they must ask before visible GitHub mutations.

### 7.1 `/ldd:setup`

Bootstraps the repo for the MVP workflow.

It should:

- verify the repo has a GitHub remote
- infer the GitHub repository and default branch
- verify `gh` is installed and authenticated
- create `docs/tickets/`
- create `.ldd/config.yml`
- create local templates for `prd.md`, `sdd.md`, `plan.md`, `plan.html`, and PR bodies
- create or confirm the ADR directory configured in `.ldd/config.yml` only when the first ADR is needed

It should not create labels or GitHub Actions in the MVP.

Minimal config:

```yaml
github:
  repo: owner/name
  default_branch: main

artifacts:
  root: docs/tickets

branches:
  prd: ldd/prd/{issue}
  sdd_plan: ldd/sdd-plan/{issue}
  implementation: ldd/impl/{issue}

prs:
  prd_title: "PRD: {title}"
  sdd_plan_title: "SDD + Plan: {title}"
  implementation_title: "{title}"

renderer:
  plan_html: true

adr:
  directory: docs/adr
  update_policy: immutable_superseded   # or mutable_existing
  filename_style: dated_slug            # or numbered
```

ADR support is mandatory. The organisation chooses how ADRs are updated.

### 7.2 `/ldd:next`

Read-only diagnostic command.

Input:

```text
/ldd:next <issue-number>
```

It reads:

- GitHub issue state
- linked PRs
- PR branch names
- PR titles and bodies
- PR review / merge state
- expected local branches
- expected local artifacts

It reports:

- where the issue is in the LDD workflow
- the next explicit command
- any inconsistency that needs human action
- whether requested changes on an open PR imply rerunning `/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`, `/ldd:design`, or `/ldd:plan`

It never mutates GitHub.

Decision tree:

```text
If issue is closed:
  done

Else if Implementation PR exists:
  inspect Implementation PR state

Else if SDD/Plan PR is merged:
  next: /ldd:implement

Else if SDD/Plan PR exists:
  inspect SDD/Plan PR state

Else if PRD PR is merged:
  next: /ldd:design

Else if PRD PR exists:
  inspect PRD PR state

Else if ldd/prd/<issue> branch exists:
  inspect prd.md completeness and recommend /ldd:scope, /ldd:elaborate, or /ldd:refine

Else:
  next: /ldd:scope
```

### 7.3 `/ldd:scope`

Creates or updates `prd.md` on `ldd/prd/<issue>`.

It focuses only on boundaries:

- goals
- non-goals
- initial dependencies or constraints

It must not fill implementation detail or acceptance criteria. Those belong to later PM steps.

Output:

- local commit on `ldd/prd/<issue>`
- no GitHub mutation unless explicitly confirmed for branch push/update

### 7.4 `/ldd:elaborate`

Updates `prd.md` on `ldd/prd/<issue>`.

It fills product detail inside the existing scope:

- problem
- users / personas
- user stories
- draft acceptance criteria
- draft success metrics
- open questions

It must not expand scope. If elaboration exposes a scope problem, it stops and recommends rerunning `/ldd:scope`.

Output:

- local commit on `ldd/prd/<issue>`

### 7.5 `/ldd:refine`

Updates `prd.md` on `ldd/prd/<issue>`.

It sharpens the PRD for engineering handoff:

- makes acceptance criteria testable
- makes success metrics measurable
- resolves or explicitly owns open questions
- verifies dependencies are named clearly
- removes vague or solution-smuggling language

Output:

- local commit on `ldd/prd/<issue>`
- summary for human review
- after human approval, push/open/update PRD PR

### 7.6 `/ldd:design`

Creates or updates `sdd.md` on `ldd/sdd-plan/<issue>`.

It reads:

- merged PRD
- relevant code
- existing ADRs under configured ADR directory

It produces:

- software design document (`sdd.md`)
- ADR creates/updates when the threshold is met

ADR threshold:

An ADR is created or updated only when a decision is:

1. hard to reverse
2. surprising without context
3. the result of a real trade-off

Mandatory ADR support does not mean mandatory ADR creation.

`/ldd:design` should not introduce a mandatory `CONTEXT.md` concept in the MVP. If a repo already has domain/context docs, the skill may read them, but MVP LDD does not require them.

Output:

- local commit on `ldd/sdd-plan/<issue>`

### 7.7 `/ldd:plan`

Creates or updates `plan.md` and `plan.html` on `ldd/sdd-plan/<issue>`.

It reads:

- merged PRD
- `sdd.md`
- relevant ADRs

It must not introduce new architectural decisions. If planning discovers a missing ADR-worthy design decision, it stops and sends the workflow back to `/ldd:design`.

`plan.md` is the durable source. `plan.html` is generated from `plan.md`.

`plan.md` should include:

- PRD summary
- SDD summary
- ADR summary and links
- implementation slices
- acceptance criteria traceability
- files / modules expected to change
- test strategy
- review checklist

`plan.html` is the human implementation review package. It exists only because the plan review is the high-cognitive-load point in the workflow.

Output:

- local commit on `ldd/sdd-plan/<issue>`
- summary for human review
- after human approval, push/open/update SDD/Plan PR

### 7.8 `/ldd:implement`

Creates or updates code and tests on `ldd/impl/<issue>`.

It reads:

- merged PRD
- merged SDD
- merged ADR changes
- merged plan
- plan HTML for review context

It executes the plan using TDD:

- one behavior/test at a time
- minimal implementation per test
- refactor only after green
- run the configured checks before PR

It must follow the approved plan. If the plan is wrong, stop and return to the earliest affected planning/design step. Do not silently update `plan.md` from implementation.

Output:

- local commits on `ldd/impl/<issue>`
- test/check summary
- after human approval, push/open/update Implementation PR

## 8. Artifact Schemas

### 8.1 PRD (`prd.md`)

```yaml
---
issue: 123
title: "<issue title>"
created: 2026-05-11
updated: 2026-05-11
---
```

Sections:

```text
# PRD: <title>

## Problem
## Goals
## Non-goals
## Users / Personas
## User Stories
## Acceptance Criteria
## Success Metrics
## Dependencies
## Open Questions
```

Ownership:

- `/ldd:scope`: Goals, Non-goals, initial Dependencies
- `/ldd:elaborate`: Problem, Users / Personas, User Stories, draft Acceptance Criteria, draft Success Metrics, Open Questions
- `/ldd:refine`: polished Acceptance Criteria, measurable Success Metrics, resolved or owned Open Questions

### 8.2 SDD (`sdd.md`)

```yaml
---
issue: 123
prd: docs/tickets/123/prd.md
created: 2026-05-11
updated: 2026-05-11
adrs:
  - docs/adr/2026-05-11-example-decision.md
---
```

Sections:

```text
# Software Design Document: <title>

## Context
## Constraints
## Existing System
## Decision Summary
## Alternatives Considered
## Proposed Design
## Data Flow / Control Flow
## Interfaces / Contracts
## Migration / Compatibility
## Observability
## Security / Privacy
## ADRs
## Open Design Questions
```

Sections may be brief for small changes. Empty boilerplate is worse than a short, honest SDD.

### 8.3 Plan (`plan.md`)

```yaml
---
issue: 123
prd: docs/tickets/123/prd.md
sdd: docs/tickets/123/sdd.md
created: 2026-05-11
updated: 2026-05-11
plan_html: docs/tickets/123/plan.html
adrs:
  - docs/adr/2026-05-11-example-decision.md
---
```

Sections:

```text
# Implementation Plan: <title>

## Review Context
### PRD Summary
### SDD Summary
### ADR Summary

## Slices
## Acceptance Criteria Traceability
## Files / Modules
## Test Strategy
## Review Checklist
```

The plan is the human implementation review point. It should be specific enough for an AI implementation agent to execute without inventing architecture.

### 8.4 Plan HTML (`plan.html`)

Generated from `plan.md` and committed.

It should render:

- PRD summary
- SDD summary
- ADR summary and links
- implementation slices
- acceptance criteria traceability
- files/modules
- test strategy
- review checklist

No other HTML artifacts are generated in the MVP. `prd.md`, `sdd.md`, and ADRs remain markdown only.

## 9. ADR Policy

ADR support is part of the MVP because SDD work can create durable architectural decisions.

`/ldd:setup` records the organisation's ADR policy:

- ADR directory
- update policy:
  - `immutable_superseded`
  - `mutable_existing`
- filename style:
  - `dated_slug`
  - `numbered`

`/ldd:design` must always check whether ADR work is needed. It writes ADR changes only when the strict threshold is met:

- hard to reverse
- surprising without context
- real trade-off

ADR changes live in the SDD/Plan branch and are reviewed in the SDD/Plan PR.

`/ldd:plan` must not introduce ADR decisions. If it discovers one, it stops and sends the user back to `/ldd:design`.

## 10. GitHub PR Bodies

LDD skills generate PR bodies directly. GitHub PR templates are not required in the MVP.

### 10.1 PRD PR Body

Must include:

- issue link
- PRD path
- summary of goals/non-goals
- reviewer prompt: "Is this ready for engineering design?"

### 10.2 SDD/Plan PR Body

Must include:

- issue link
- PRD link
- SDD link
- plan.md link
- plan.html link
- ADR links if present
- reviewer prompt: "Does this design and plan correctly implement the PRD?"

### 10.3 Implementation PR Body

Must include:

- issue link with `Closes #<issue>`
- PRD link
- SDD link
- plan.md link
- plan.html link
- ADR links if present
- test/check summary
- reviewer prompt: "Does this implementation follow the approved plan?"

## 11. Non-Goals

- No broad issue triage.
- No incidents or hotfix modelling.
- No retrofit artifacts.
- No epic decomposition.
- No phase or gate labels.
- No PR labels.
- No generated `progress.md`.
- No automatic GitHub Actions for workflow transitions.
- No backend abstraction beyond GitHub.
- No mandatory domain dictionary or `CONTEXT.md`.

## 12. Future Work

Consider only after MVP use reveals real pain:

- `/ldd:triage`
- epics and decomposition
- richer reporting labels
- GitHub Actions to verify generated `plan.html`
- JIRA / Linear / files adapters
- domain dictionary support
- cross-ticket dependency graph
- issue discovery commands such as "show me all LDD work needing attention"

## 13. Glossary

- **Ledger** — GitHub, specifically Issues and PRs, as the source of workflow state.
- **PRD** — Product Requirements Document. PM-owned statement of what should be built and why.
- **SDD** — Software Design Document. SE-owned technical design for how the PRD should be implemented.
- **Plan** — implementation plan reviewed before code. Source is `plan.md`; human review package is `plan.html`.
- **ADR** — Architecture Decision Record. Created or updated only for durable, surprising, trade-off-based decisions.
- **PM hat** — the scope/elaborate/refine mode.
- **SE hat** — the design/plan mode.
- **Implementation hat** — the TDD execution mode.
