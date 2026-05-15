# Ledger-Driven Development

Ledger-Driven Development is a workflow for AI-assisted software delivery where product scope, engineering design, planning, and implementation move through explicit reviewable handoffs.

## Language

**Ledger**:
A repo-local, machine-readable record of an LDD ticket's workflow state, artifact state, external tracker links, and synchronization status.
_Avoid_: GitHub issue, progress log, audit log, task list

**Ticket**:
The unit of LDD work that carries one product requirement through design, planning, and implementation.
_Avoid_: GitHub issue, task, story

**Product Requirement**:
The product-scope artifact that defines what should be built and why before engineering design begins.
_Avoid_: implementation ticket, design brief, GitHub issue body

**Research Artifact**:
A sanitized pre-scope artifact that gathers PM-grade inputs, codebase facts, assumptions, risks, sensitivity handling, and open questions before a Product Requirement boundary is written.
_Avoid_: PRD, design brief, raw private notes

**Input Quality Gate**:
A command-local standard that validates whether the current phase has enough approved or source input before writing or mutating its artifact.
_Avoid_: best-effort guess, implicit assumption, silent artifact mutation

**Local Ticket ID**:
A repo-assigned identifier for a **Ticket** that has no configured external tracker identity.
_Avoid_: GitHub issue number, Linear issue key, Jira issue key

**Draft Ticket Directory**:
A temporary repo-local workspace for a **Product Requirement** before it is ready to create or bind to an external tracker record.
_Avoid_: final ticket directory, progress folder, scratchpad

**Active Draft**:
A **Draft Ticket Directory** that has not yet been promoted or archived.
_Avoid_: promoted ticket, current project, global active ticket

**Draft Slug**:
A short human-readable phrase embedded in a **Draft Ticket Directory** name to describe the emerging **Product Requirement**.
_Avoid_: final ticket identifier

**Promoted Ticket Directory**:
The stable repo-local directory for a **Ticket** after its final ticket identifier has been assigned.
_Avoid_: draft directory

**Ticket Promotion**:
The transition that assigns the final ticket identifier and moves a **Draft Ticket Directory** to a **Promoted Ticket Directory**.
_Avoid_: publish, sync, submit

**Ledger Event**:
A compact append-only record of an important workflow transition for one **Ticket**.
_Avoid_: progress update, audit trail, session log

**Execution Context**:
A compact section in a **Ledger** that records the current phase, gate, approved inputs, work boundaries, and next command or human action for one **Ticket**.
_Avoid_: global status, progress file, chat summary

**Bounded Shared Understanding Gate**:
A Product Manager command checkpoint where the agent proves it understands the user's product boundary before writing or approving PRD content, without expanding the current PRD to include every related idea.
_Avoid_: open-ended challenge session, hidden feature expansion

**External Tracker**:
A configured system outside the repository that can host the reviewable tracker record for a **Product Requirement**.
_Avoid_: ledger, source of truth

**External Tracker ID**:
The identifier assigned by an **External Tracker** to the reviewable tracker record for a **Product Requirement**.
_Avoid_: Local Ticket ID

**Child Work Item**:
A story, subtask, or implementation ticket that rolls up to one parent **Product Requirement**.
_Avoid_: independent PRD

**Vertical Slice**:
A plan-derived child work item that delivers a narrow, independently reviewable path through the required functionality.
_Avoid_: layer task, component task, arbitrary subtask

**Decomposition**:
The conscious post-plan step that turns an approved implementation plan into **Vertical Slices**.
_Avoid_: planning, implementation, auto-decomposition

**Workflow Navigation**:
The read-only act of identifying the next LDD command from the current **Ledger** state.
_Avoid_: orchestration, dispatch, execution

**Verification**:
The child-work gate that checks implementation evidence, required checks, traceability, and drift before recommending closure.
_Avoid_: repository healthcheck, implementation, archive

**Closure**:
The post-verification decision to mark child work done and optionally close its external tracker projection after human approval.
_Avoid_: implementation completion, verification pass, automatic close

**Close Command**:
The LDD command that applies **Closure** after **Verification** has passed.
_Avoid_: verification, implementation, automatic archive

**Archive Command**:
The optional LDD command that moves already-closed ticket files into the **Ticket Archive** as storage cleanup.
_Avoid_: closure decision, verification, external tracker mutation

**Parent Roll-up Closure**:
Closing a parent **Product Requirement** only after every **Child Work Item** is already closed or verified and closeable.
_Avoid_: partial parent close, implied completion, child bypass

**Verified Child Work**:
A **Child Work Item** with passing **Verification** recorded in its **Ledger** and a readable `verification.md` report.
_Avoid_: closed ticket, archived work, merged code

**Agent Skills Manifest**:
The repo-root `agent-skills.json` file that lists the installable LDD skills and adapter manifests.
_Avoid_: LDD-specific manifest, command registry, package lock

**Standalone Skill Contract**:
The rule that every installed LDD command must include its own workflow instructions and must not require other installed skills to run correctly.
_Avoid_: external skill dependency, hidden prerequisite

**Installed Skill Copy**:
A copy of an LDD skill installed into an agent-specific local skills directory.
_Avoid_: live link, source of truth

**External Ticket Projection**:
A human-readable external tracker issue generated from LDD ledger and artifact state.
_Avoid_: canonical state, thin ID placeholder

**GitHub-first Projection**:
The first supported external tracker visibility path: GitHub issues for Product Requirement, SDD, and Child Work Item visibility; native GitHub sub-issues for Child Work Item hierarchy where supported; and GitHub PRs for implementation review.
_Avoid_: source of truth, sync engine, Linear/Jira parity

**External Drift**:
A detected change in an external tracker record since LDD last synchronized its generated projection.
_Avoid_: automatic conflict resolution

**Active Ticket Tree**:
The repo-local ticket directories that contain current work visible to normal LDD commands.
_Avoid_: archive

**Ticket Archive**:
The repo-local storage area for completed child work items and closed parent tickets that should no longer appear in normal workflow navigation.
_Avoid_: active ticket tree, deletion

## Relationships

- A **Ledger** belongs to exactly one **Ticket**.
- A **Ticket** has exactly one **Product Requirement**.
- A **Ticket** has exactly one **Ledger**.
- A **Ledger** may link to external tracker records, but those records are not the canonical LDD state.
- A **Local Ticket ID** is used only when a **Ticket** has no configured **External Tracker** identity.
- A **Draft Ticket Directory** exists before a **Product Requirement** is ready for review in an **External Tracker**.
- Every **Product Requirement** starts in a **Draft Ticket Directory**.
- A **Research Artifact** may exist before a **Product Requirement** is scoped, but it does not define scope.
- A **Research Artifact** may use full read-only repository and private/local context visibility, while committed output contains only sanitized conclusions.
- An **Input Quality Gate** belongs to one command and must name the missing input and earliest repairing LDD command when it rejects work.
- A **Draft Ticket Directory** uses a date and **Draft Slug** for human context.
- An incomplete **Promoted Ticket Directory** does not block creating a new **Draft Ticket Directory**.
- Multiple **Promoted Ticket Directories** may be active at different LDD phases.
- Local mode keeps at most one **Active Draft** to avoid ambiguous Product Manager work.
- If an **Active Draft** already exists, new scoping work continues that draft or explicitly resolves it before starting another.
- A **Ticket Promotion** assigns either a **Local Ticket ID** or an **External Tracker ID** as the final ticket identifier. In GitHub tracker mode, the GitHub issue number is the final ticket identifier.
- A **Ticket Promotion** moves the **Draft Ticket Directory** to a **Promoted Ticket Directory**.
- A **Promoted Ticket Directory** name is stable after review starts.
- A **Ledger** contains current state and a small history of **Ledger Events**.
- A **Ledger** may contain **Execution Context** for exactly its own **Ticket**.
- **Execution Context** never creates global workflow state.
- A **Bounded Shared Understanding Gate** protects Product Manager work before PRD approval.
- A **Bounded Shared Understanding Gate** must route new scope to `/ldd:scope`, a later phase, or a separate **Product Requirement** instead of silently expanding the current PRD.
- A **Child Work Item** belongs to exactly one parent **Product Requirement**.
- A **Vertical Slice** is the preferred form of **Child Work Item** for implementation.
- A **Vertical Slice** may be independent or may depend on other **Vertical Slices**.
- A **Decomposition** produces **Vertical Slices** that reference their parent **Product Requirement** and approved plan.
- Implementation never performs **Decomposition** automatically.
- Implementation completion does not imply **Verification** or **Closure**.
- **Verification** applies to **Child Work Items**, not general repository health.
- **Verification** writes a readable report and machine-readable **Ledger** state.
- **Verified Child Work** is eligible for human closure review.
- **Closure** remains separate from **Verification** and records external tracker mutation only after explicit human confirmation.
- The **Close Command** requires passed **Verification** before workflow close.
- **Parent Roll-up Closure** requires every **Child Work Item** to be closed or verified and closeable.
- The **Archive Command** is optional cleanup after **Closure** and must not be required for workflow completion.
- If implementation finds no **Vertical Slices**, it reports that there are no tickets to implement.
- If implementation finds an approved plan without **Vertical Slices**, it reports that **Decomposition** is required.
- **Workflow Navigation** identifies the next step but does not perform it.
- Completed **Child Work Items** and closed parent tickets may move from the **Active Ticket Tree** to the **Ticket Archive** only through optional archival cleanup.
- **Workflow Navigation** ignores the **Ticket Archive** by default.
- The **Agent Skills Manifest** is the package source of truth for installable LDD skills.
- The **Standalone Skill Contract** applies to every `/ldd:*` command.
- An **Installed Skill Copy** can become stale and must be updated from the **Agent Skills Manifest**.
- An **External Ticket Projection** must be useful to a PM, TPM, Director, or implementation agent without requiring them to open repository files.
- A **GitHub-first Projection** is the initial dogfooding path for external visibility.
- Linear and Jira are follow-on optional collaboration surfaces until the **GitHub-first Projection** model is proven.
- GitHub issues project **Product Requirement**, SDD, and **Child Work Item** visibility; GitHub native sub-issues project **Child Work Item** hierarchy where supported; GitHub PRs project implementation review.
- In GitHub tracker mode, SDD approval creates or binds an SDD issue that references the parent **Product Requirement** issue. Decomposition-created **Child Work Item** issues must be attached as native sub-issues of the SDD issue when GitHub supports sub-issues, so the **Product Requirement** may have grandchildren in the external projection. Body links to the SDD issue are backup traceability, not a substitute for native sub-issue hierarchy when available.
- **External Drift** stops automatic sync until a human decides whether to import, preserve, or overwrite the external contribution.

## Example dialogue

> **Dev:** "If GitHub says the PRD PR is merged but the local ledger says the PRD is still draft, which state wins?"
> **Domain expert:** "The **Ledger** is canonical for LDD state. The GitHub state is external sync input, so the command should report drift and ask before reconciling."

## Flagged ambiguities

- "Ledger" previously meant GitHub Issues and Pull Requests. Resolved: **Ledger** now means repo-local canonical workflow state; GitHub, Linear, and Jira are external sync targets.
- "ticket", "epic", "story", and "subtask" were used interchangeably. Resolved: **Product Requirement** is the parent review unit; **Child Work Item** is the implementation/decomposition unit that rolls up to it.
- "`ldd-core`" previously meant a shared installed skill. Resolved: there is no installed core skill; shared rules live in each command-shaped skill and package discovery lives in the **Agent Skills Manifest**.
- "External ticket" previously meant a thin identifier binding. Resolved: external tickets are rich projections that may receive external contributions and therefore require drift detection.
- "TDD" is an implementation discipline embedded in `/ldd:implement`, not a dependency on another installed skill.
