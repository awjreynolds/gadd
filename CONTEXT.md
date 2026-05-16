# GADD

Governed Autonomy is the operating philosophy for AI-assisted work that keeps authority, scope, evidence, and approval boundaries explicit. GADD is the software-delivery methodology that applies that philosophy across triage, product scope, engineering design, planning, implementation, verification, and closure.

## Language

**Ledger**:
A repo-local, machine-readable record of one Work Item's workflow state, artifact state, external tracker links, and synchronization status.
_Avoid_: GitHub issue, progress log, audit log, task list

**Work Item**:
The canonical repo-local unit of GADD-governed work.
_Avoid_: ticket, issue, story

**External Issue**:
A tracker-native GitHub, Linear, Jira, or similar record that can source or project a Work Item.
_Avoid_: canonical ledger state

**Triage Outcome**:
The approved route decision for an unclassified Work Item, made from triage evidence, GitNexus impact evidence, and human approval where required.
_Avoid_: permanent local triage brief

**Triage Quality Loop**:
The bounded clarification loop inside `/gadd:triage` that improves poor-quality intake only until the Work Item can route responsibly.
_Avoid_: switching into a separate brainstorming or grill-me workflow

**Product Requirement**:
The product-scope artifact and Work Item type that defines what should be built and why before engineering design begins.
_Avoid_: implementation task, design brief, external issue body

**Research Artifact**:
A sanitized pre-scope artifact that gathers PM-grade inputs, codebase facts, assumptions, risks, sensitivity handling, and open questions before a Product Requirement boundary is written.
_Avoid_: PRD, design brief, raw private notes

**Input Quality Gate**:
A command-local standard that validates whether the current phase has enough approved or source input before writing or mutating its artifact.
_Avoid_: best-effort guess, implicit assumption, silent artifact mutation

**Work Item ID**:
A repo-assigned or external-tracker-derived identifier for a Work Item.
_Avoid_: assuming the identifier itself is canonical state

**Draft Work Item Directory**:
A temporary repo-local workspace for a Work Item before it is ready to promote or bind to an External Issue.
_Avoid_: final Work Item directory, progress folder, scratchpad

**Active Draft**:
A Draft Work Item Directory that has not yet been promoted or archived.
_Avoid_: promoted Work Item, current project, global active item

**Draft Slug**:
A short human-readable phrase embedded in a Draft Work Item Directory name to describe the emerging Work Item.
_Avoid_: final Work Item identifier

**Promoted Work Item Directory**:
The stable repo-local directory for a Work Item after its final identifier has been assigned.
_Avoid_: draft directory

**Work Item Promotion**:
The transition that assigns the final Work Item identifier and moves a Draft Work Item Directory to a Promoted Work Item Directory.
_Avoid_: publish, sync, submit

**Ledger Event**:
A compact append-only record of an important workflow transition for one Work Item.
_Avoid_: progress update, audit trail, session log

**Execution Context**:
A compact section in a Ledger that records the current phase, gate, approved inputs, work boundaries, and next command or human action for one Work Item.
_Avoid_: global status, progress file, chat summary

**Bounded Shared Understanding Gate**:
A Product Requirement lane checkpoint where the agent proves it understands the user's product boundary before writing or approving PRD content, without expanding the current PRD to include every related idea.
_Avoid_: open-ended challenge session, hidden feature expansion

**External Tracker**:
A configured system outside the repository that can host reviewable External Issues and Pull Requests.
_Avoid_: ledger, source of truth

**External Tracker ID**:
The identifier assigned by an External Tracker to the reviewable External Issue for a Work Item.
_Avoid_: Work Item ID unless the ledger records the binding

**Child Work Item**:
A planned implementation slice that rolls up to a parent Work Item when decomposition is needed.
_Avoid_: independent PRD

**Vertical Slice**:
A plan-derived Child Work Item that delivers a narrow, independently reviewable path through the required functionality.
_Avoid_: layer task, component task, arbitrary subtask

**Decomposition**:
The conscious post-plan step that turns an approved implementation plan into Vertical Slices.
_Avoid_: planning, implementation, auto-decomposition

**Workflow Navigation**:
The read-only act of identifying the next GADD command from the current Ledger state.
_Avoid_: orchestration, dispatch, execution

**Verification**:
The Work Item gate that checks implementation evidence, required checks, traceability, and drift before recommending closure.
_Avoid_: repository healthcheck, implementation, archive

**Closure**:
The post-verification decision to mark work done and optionally close its External Issue projection after human approval.
_Avoid_: implementation completion, verification pass, automatic close

**Close Command**:
The GADD command that applies Closure after Verification has passed.
_Avoid_: verification, implementation, automatic archive

**Archive Command**:
The optional GADD command that moves already-closed Work Item files into the Work Item archive as storage cleanup.
_Avoid_: closure decision, verification, external tracker mutation

**Parent Roll-up Closure**:
Closing a parent Work Item only after every Child Work Item is already closed or verified and closeable.
_Avoid_: partial parent close, implied completion, child bypass

**Verified Work Item**:
A Work Item with passing Verification recorded in its Ledger and a readable `verification.md` report.
_Avoid_: closed item, archived work, merged code

**Agent Skills Manifest**:
The repo-root `agent-skills.json` file that lists the installable GADD skills and adapter manifests.
_Avoid_: GADD-specific manifest, command registry, package lock

**Standalone Skill Contract**:
The rule that every installed GADD command must include its own workflow instructions and must not require other installed skills to run correctly.
_Avoid_: external skill dependency, hidden prerequisite

**Installed Skill Copy**:
A copy of a GADD skill installed into an agent-specific local skills directory.
_Avoid_: live link, source of truth

**External Projection**:
A human-readable external tracker record generated from GADD ledger and artifact state.
_Avoid_: canonical state, thin ID placeholder

**GitHub-first Projection**:
The first supported external tracker visibility path: GitHub issues for Product Requirement, SDD, and Work Item visibility; native GitHub sub-issues for Child Work Item hierarchy where supported; and GitHub PRs for implementation review.
_Avoid_: source of truth, sync engine, Linear/Jira parity

**External Drift**:
A detected change in an external tracker record since GADD last synchronized its generated projection.
_Avoid_: automatic conflict resolution

**Active Work Item Tree**:
The repo-local Work Item directories that contain current work visible to normal GADD commands.
_Avoid_: archive

**Work Item Archive**:
The repo-local storage area for completed Work Items that should no longer appear in normal workflow navigation.
_Avoid_: active Work Item tree, deletion

## Relationships

- A Work Item has exactly one repo-local Ledger.
- A Work Item may bind to an External Issue, but the External Issue is not canonical workflow state.
- A Work Item may be a `bug_fix`, `task`, `engineering_change`, `product_requirement`, `external_issue_intake`, or `not_gadd_work`.
- Product Requirement work is one Work Item type, not the only GADD entry path.
- In external-tracker mode, the triage narrative is projected to the External Issue after human approval; the Ledger records route and sync metadata.
- A Ledger may contain Execution Context for exactly its own Work Item.
- Execution Context never creates global workflow state.
- A Work Item starts in a Draft Work Item Directory when it is not already bound to an External Issue.
- Work Item Promotion assigns either a local Work Item ID or an External Tracker ID as the stable identifier.
- A Promoted Work Item Directory name is stable after review starts.
- A Research Artifact may exist before a Product Requirement is scoped, but it does not define scope.
- A Research Artifact may use full read-only repository and private/local context visibility, while committed output contains only sanitized conclusions.
- An Input Quality Gate belongs to one command and must name the missing input and earliest repairing GADD command when it rejects work.
- A Triage Quality Loop stops when the Work Item can route to implementation, SDD, PRD discovery, or terminal handling.
- A Triage Outcome may route to `/gadd:implement`, `/gadd:design`, `/gadd:research`, `/gadd:scope`, or terminal handling.
- A Bounded Shared Understanding Gate protects Product Requirement lane work before PRD approval.
- A Bounded Shared Understanding Gate must route new scope to `/gadd:scope`, a later phase, or a separate Product Requirement instead of silently expanding the current PRD.
- A Child Work Item belongs to exactly one parent Work Item.
- A Vertical Slice is the preferred form of Child Work Item for implementation.
- A Vertical Slice may be independent or may depend on other Vertical Slices.
- Decomposition produces Vertical Slices that reference their parent Work Item and approved plan.
- Implementation never performs Decomposition automatically.
- Implementation completion does not imply Verification or Closure.
- Verification applies to Work Items, not general repository health.
- Verification writes a readable report and machine-readable Ledger state.
- Verified Work Items are eligible for human closure review.
- Closure remains separate from Verification and records external tracker mutation only after explicit human confirmation.
- The Close Command requires passed Verification before workflow close.
- Parent Roll-up Closure requires every Child Work Item to be closed or verified and closeable.
- The Archive Command is optional cleanup after Closure and must not be required for workflow completion.
- If implementation finds no ready Work Items, it reports that there is no implementation work to run.
- If implementation finds an approved plan without Vertical Slices, it reports that Decomposition is required.
- Workflow Navigation identifies the next step but does not perform it.
- Completed Work Items may move from the Active Work Item Tree to the Work Item Archive only through optional archival cleanup.
- Workflow Navigation ignores the Work Item Archive by default.
- The Agent Skills Manifest is the package source of truth for installable GADD skills.
- The Standalone Skill Contract applies to every `/gadd:*` command.
- An Installed Skill Copy can become stale and must be updated from the Agent Skills Manifest.
- An External Projection must be useful to a PM, TPM, Director, or implementation agent without requiring them to open repository files.
- A GitHub-first Projection is the initial dogfooding path for external visibility.
- Linear and Jira are follow-on optional collaboration surfaces until the GitHub-first Projection model is proven.
- GitHub issues project Product Requirement, SDD, and Work Item visibility; GitHub native sub-issues project Child Work Item hierarchy where supported; GitHub PRs project implementation review.
- In GitHub tracker mode, SDD approval creates or binds an SDD issue that references the parent Product Requirement issue. Decomposition-created Child Work Item issues must be attached as native sub-issues of the SDD issue when GitHub supports sub-issues. Body links to the SDD issue are backup traceability, not a substitute for native sub-issue hierarchy when available.
- External Drift stops automatic sync until a human decides whether to import, preserve, or overwrite the external contribution.

## Example dialogue

> **Dev:** "If GitHub says the PRD PR is merged but the local ledger says the Work Item is still draft, which state wins?"
> **Domain expert:** "The **Ledger** is canonical for GADD state. GitHub is external sync input, so the command should report drift and ask before reconciling."

## Flagged ambiguities

- "Ledger" previously meant GitHub Issues and Pull Requests. Resolved: Ledger now means repo-local canonical workflow state; GitHub, Linear, and Jira are external sync targets.
- "Ticket", "epic", "story", and "subtask" were used interchangeably. Resolved: Work Item is the canonical governed unit; Product Requirement is one Work Item type; Child Work Item is the decomposition unit.
- "`gadd-core`" previously meant a shared installed skill. Resolved: there is no installed core skill; shared rules live in each command-shaped skill and package discovery lives in the Agent Skills Manifest.
- "External ticket" previously meant a thin identifier binding. Resolved: External Issues are rich projections that may receive external contributions and therefore require drift detection.
- "TDD" is an implementation discipline embedded in `/gadd:implement`, not a dependency on another installed skill.
