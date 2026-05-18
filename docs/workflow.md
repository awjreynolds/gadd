# GADD Workflow Details

This document expands the workflow model summarized in the README. The README is the public front door; this file holds the deeper mechanics.

## Source Of Truth

- Workflow state: repo-local `ledger.yml` files in Work Item directories under `gadd/work-items/` in the target project.
- Skill package: `agent-skills.json`.
- Command behavior: `skills/gadd-*/SKILL.md`.
- Claude adapters: `commands/gadd/*.md`.
- Gemini adapters: `commands/gadd/*.toml` plus `GEMINI.md`.

External trackers are optional review and sync surfaces. They are not canonical GADD state.

GADD is a software-delivery application of [Governed Autonomy](governed-autonomy/README.md). The broader Governed Autonomy docs explain the business-process philosophy, operating model, uncontrolled AI risk patterns, and GADD case study.

GitNexus is the strongly recommended code-intelligence surface when code reality matters. GADD treats GitNexus as advisory evidence, not canonical workflow state. If GitNexus is unavailable, stale, unindexed, or outside the configured related repositories, commands continue with normal repository inspection and record the limitation.

## Intake And Triage

GADD has two entry paths:

- Known product discovery starts with `/gadd:research` or `/gadd:scope`.
- Unclassified intake starts with `/gadd:triage`, including free-form prompts such as `/gadd:triage create a new release of this package`.

`/gadd:triage` creates or binds a Work Item, normalizes poor-quality prompts or external issues, uses GitNexus for blast-radius evidence when code reality matters, and records the route decision in the Work Item ledger.

Triage routes:

- `ready_for_implementation` -> `/gadd:implement <work-item-id>`
- `needs_sdd` -> `/gadd:design <work-item-id>`
- `needs_prd` -> `/gadd:research <work-item-id>` or `/gadd:scope <work-item-id>`
- `needs_info`, `duplicate`, `out_of_scope`, `not_gadd_work`, or `blocked_on_human_decision` -> remain in triage or terminal handling

In external-tracker mode, the human-facing triage narrative is projected to the external issue body or comments after human approval. The repo-local ledger stores workflow state, external binding, sync hashes, GitNexus evidence summary, and projection links.

## Workflow Roles

| Lane | SDLC focus | Inputs | GADD skills | Outputs |
| --- | --- | --- | --- | --- |
| Intake | Requirements Analysis | Free-form prompts, external issues, bug reports, tasks, support signals, ambiguous requests, optional GitNexus context | `/gadd:triage`, `/gadd:next` | Work Item ledger, approved triage outcome, optional external projection |
| Product Requirement Lane | Requirements Analysis | Customer pain, business goal, roadmap context, current workflow, constraints, existing product behavior, repository context, Work Items routed with `needs_prd` | `/gadd:research`, `/gadd:scope`, `/gadd:elaborate`, `/gadd:refine`, `/gadd:approve` | approved `prd.md` with acceptance criteria, non-goals, constraints, and repo-informed risks |
| Technical Design | Design | Approved PRD or approved triage outcome, repo context, Architecture Decision Records, technical constraints, related repositories | `/gadd:design`, `/gadd:plan`, `/gadd:approve`, `/gadd:decompose` | repo-scoped `sdd.md`, `plan.md`, `plan.html`, Work Item slices |
| Software Engineering | Development | Ready Work Item, approved boundary, codebase, tests, documentation obligation | `/gadd:implement <work-item-id>`, `/gadd:implement ALL` with built-in Test-Driven Development (TDD) | bounded code diff or Pull Request, tests, refactoring, implementation evidence, documentation impact evidence |
| Engineering Review | Testing / Verification | Implementation evidence, required checks, approved artifacts or triage outcome, PR state, drift metadata | `/gadd:verify`, `/gadd:close`, `/gadd:archive` | `verification.md`, closure readiness, closed ledger state, optional external tracker projection |

Engineering Managers, Technical Program Managers, Product Managers, and delivery stakeholders use the workflow for dependency, sequencing, roadmap, capacity, review-load, and status visibility. They do not own a separate GADD artifact or approval gate.

## MVP Workflow

```text
unclassified intake
  -> /gadd:triage
  -> triage outcome
  -> implementation, SDD, PRD discovery, or terminal handling

known product discovery
  -> optional research
  -> Product Requirement Work Item
  -> PRD approval with /gadd:approve
  -> SDD/Plan
  -> SDD and plan approval with /gadd:approve
  -> optional Work Item slices
  -> implementation
  -> verification
  -> human-approved closure
  -> optional local archive cleanup
```

The repo-local `ledger.yml` is canonical. `/gadd:triage` records Work Item type, state, route, external binding, GitNexus evidence summary, sync hashes, projection links, and the next command. `/gadd:refine` commits the final PRD and routes PRD approval to `/gadd:approve <work-item-id>`. In local mode, a promoted stable Work Item directory such as `gadd/work-items/GADD-0001-short-slug/` is the repo-local state package. In GitHub tracker mode, approval creates or binds the GitHub issue first, then records the GitHub issue number in the Work Item ledger. External trackers are synchronized only when configured and approved by the human.

New Product Requirements can be scoped while other promoted Work Items are still in progress. `/gadd:scope` creates or updates the local draft Work Item directory; incomplete promoted Work Items do not block new draft PRDs. Local mode keeps one active draft, so starting another draft first requires continuing, renaming, promoting, or discarding the existing draft.

`/gadd:research` gathers Product Manager-grade inputs before scoping when the trigger is weak, sensitive, or requires codebase investigation. Research has full read-only visibility into repository files, docs, existing GADD artifacts, GitNexus code-intelligence context when available, and human-supplied private/local context, but it writes only sanitized conclusions, codebase facts, explicit uncertainties, risks, sensitivity handling, open questions, and one readiness decision.

`/gadd:design` is the strongest GitNexus consumer. It strongly recommends GitNexus-backed discovery before deciding affected repositories, SDD boundaries, cross-repo sequencing, and contract risks. GitNexus is advisory: stale or unavailable indexes are recorded as limitations rather than blocking GADD unless a team policy or approved plan explicitly requires fresh GitNexus evidence.

Product Requirement lane commands use a bounded shared-understanding gate before a PRD can move forward. That gate keeps the useful part of grill-style questioning: the agent must prove it understands the user's intended boundary, blocker, and handoff criteria. It is bounded so the conversation does not absorb every related idea into the current PRD; weak inputs route to `/gadd:research`, new scope routes back to `/gadd:scope`, a later phase, or a separate PRD.

Every GADD phase has an input quality gate. A command must validate its source inputs before writing or mutating artifacts; when inputs fail the standard, it names the blocking gap and the earliest GADD command that can repair it.

## Handoff Artifacts

`/gadd:setup` installs templates into a target repository:

```text
gadd/config.yml
gadd/templates/work-item-ledger.yml
gadd/templates/triage.md
gadd/templates/research.md
gadd/templates/prd.md
gadd/templates/sdd.md
gadd/templates/plan.md
gadd/templates/plan.html
gadd/templates/issue-body-work-item.md
gadd/templates/issue-body-prd.md
gadd/templates/issue-body-sdd.md
gadd/templates/pr-body-prd.md
gadd/templates/pr-body-sdd-plan.md
gadd/templates/pr-body-implementation.md
gadd/templates/verification.md
gadd/work-items/_drafts/
gadd/work-items/_archive/
```

The templates are quality contracts, not blank forms:

- Work Item ledgers keep workflow state separate from external issue bodies and comments.
- Triage narratives are human-facing projections of the approved triage outcome. In external-tracker mode they are projected after human approval; in local-only mode they can be stored as `triage.md`.
- PRDs keep product scope separate from technical design.
- Research artifacts gather standard Product Manager inputs, codebase facts, and sensitivity handling before scope without becoming product scope or engineering design.
- GitNexus is strongly recommended code intelligence for triage, research, design, planning, and optional verification evidence; it never replaces the repo-local ledger.
- `/gadd:approve` records explicit human approval for PRD, SDD, and plan gates. It does not approve decomposition, closure, or external mutations.
- SDDs translate approved PRDs or approved triage outcomes into designs grounded in code and ADRs.
- SDD templates include a required `## Structure` section immediately after the title. This is the SDD's header-file summary: a concise map of design intent, components, responsibility boundaries, interfaces, flow, explicit non-changes, and where to read the detailed rationale.
- Plans trace acceptance criteria to implementation slices and verification.
- Plans and Work Item slices must record documentation impact for each slice: updated, not needed with reason, or blocked.
- Decomposition turns approved plan slices into Child Work Items.
- Implementation completes Work Items but does not close them. Implementation evidence must include documentation impact, changed documentation paths, or a direct docs-not-needed rationale.
- Verification checks Work Item closure readiness before workflow close, including documentation impact for the implemented work.
- Close applies verified closure, keeps local Work Item paths stable, and can close a parent only when every child is verified and closeable. In GitHub mode, issue closure is an explicit external mutation recorded as evidence.
- Archive is optional storage cleanup for already-closed local Work Item packages.
- Child Work Items follow GADD's standalone independently-grabbable shape: parent, what to build, acceptance criteria, blockers, user stories covered, and GADD traceability.
- PR bodies focus reviewers on the correct handoff question.

## Planning-System Projections

GitHub is the first external-tracker dogfooding path:

- GitHub issues project Product Requirement, SDD, and Work Item visibility.
- For `product_requirement` work, SDD issues are children of PRD issues. For `engineering_change` work, SDD issues project the approved triage outcome directly without requiring a parent PRD issue. Implementation Child Work Items created by decomposition are native GitHub sub-issues of the SDD issue when GitHub supports sub-issues.
- GitHub Pull Requests project implementation review.
- GADD updates managed GitHub bodies only after explicit human confirmation and drift checks.
- Linear and Jira remain follow-on optional collaboration surfaces until the GitHub model is proven.

Current maturity:

| Surface | Status |
| --- | --- |
| Local ledger | Canonical and always supported |
| GitHub | First dogfooding path for issues, sub-issues, and Pull Request review projections |
| Linear | Important planning surface, not validated support yet |
| Jira | Important enterprise planning surface, not validated support yet |
| Asana | Candidate roadmap/cross-functional planning surface, not validated support yet |
| Trello and internal trackers | Adaptive projection examples, not validated support yet |

External issue bodies are rich projections of the ledger and artifacts, readable without opening the repo.
