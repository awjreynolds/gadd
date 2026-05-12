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

**Local Ticket ID**:
A repo-assigned identifier for a **Ticket** that has no configured external tracker identity.
_Avoid_: GitHub issue number, Linear issue key, Jira issue key

**Draft Ticket Directory**:
A temporary repo-local workspace for a **Product Requirement** before it is ready to create or bind to an external tracker record.
_Avoid_: final ticket directory, progress folder, scratchpad

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

**External Drift**:
A detected change in an external tracker record since LDD last synchronized its generated projection.
_Avoid_: automatic conflict resolution

**Active Ticket Tree**:
The repo-local ticket directories that contain current work visible to normal LDD commands.
_Avoid_: archive

**Ticket Archive**:
The repo-local storage area for completed child work items that should no longer appear in normal workflow navigation.
_Avoid_: active ticket tree, deletion

## Relationships

- A **Ledger** belongs to exactly one **Ticket**.
- A **Ticket** has exactly one **Product Requirement**.
- A **Ticket** has exactly one **Ledger**.
- A **Ledger** may link to external tracker records, but those records are not the canonical LDD state.
- A **Local Ticket ID** is used only when a **Ticket** has no configured **External Tracker** identity.
- A **Draft Ticket Directory** exists before a **Product Requirement** is ready for review in an **External Tracker**.
- Every **Product Requirement** starts in a **Draft Ticket Directory**.
- A **Draft Ticket Directory** uses a date and **Draft Slug** for human context.
- A **Ticket Promotion** assigns either a **Local Ticket ID** or an **External Tracker ID** as the final ticket identifier.
- A **Ticket Promotion** moves the **Draft Ticket Directory** to a **Promoted Ticket Directory**.
- A **Promoted Ticket Directory** name is stable after review starts.
- A **Ledger** contains current state and a small history of **Ledger Events**.
- A **Child Work Item** belongs to exactly one parent **Product Requirement**.
- A **Vertical Slice** is the preferred form of **Child Work Item** for implementation.
- A **Vertical Slice** may be independent or may depend on other **Vertical Slices**.
- A **Decomposition** produces **Vertical Slices** that reference their parent **Product Requirement** and approved plan.
- Implementation never performs **Decomposition** automatically.
- If implementation finds no **Vertical Slices**, it reports that there are no tickets to implement.
- If implementation finds an approved plan without **Vertical Slices**, it reports that **Decomposition** is required.
- **Workflow Navigation** identifies the next step but does not perform it.
- Completed **Child Work Items** move from the **Active Ticket Tree** to the **Ticket Archive**.
- **Workflow Navigation** ignores the **Ticket Archive** by default.
- The **Agent Skills Manifest** is the package source of truth for installable LDD skills.
- The **Standalone Skill Contract** applies to every `/ldd:*` command.
- An **Installed Skill Copy** can become stale and must be updated from the **Agent Skills Manifest**.
- An **External Ticket Projection** must be useful to a PM, TPM, Director, or implementation agent without requiring them to open repository files.
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
