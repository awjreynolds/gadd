---
ticket: 1
prd: docs/tickets/1-add-research-and-phase-gates/prd.md
created: 2026-05-14
updated: 2026-05-14
status: approved
adrs: []
---

# Software Design Document: Add LDD research and phase input gates

## Context

The approved PRD requires LDD to stop producing PRDs from weak context, add a first-class `/ldd:research` phase, and apply input-quality gates across the workflow. It also requires research to have full read-only code visibility while keeping financially sensitive or private PM inputs out of committed and GitHub-visible artifacts.

- PRD: `docs/tickets/1-add-research-and-phase-gates/prd.md`
- Existing entry points: `skills/ldd-*/SKILL.md`, `commands/ldd/*.md`, `commands/ldd/*.toml`, `agent-skills.json`, `.claude-plugin/plugin.json`, `gemini-extension.json`, `skills/ldd-setup/assets/templates/*`, and `scripts/validate-ldd-mvp.sh`
- Relevant ADRs: none found under `docs/`
- Terms from the codebase/domain glossary: Repo-local Ledger, Execution Context, Product Requirement, GitHub-first Projection, Standalone Skill Contract, Bounded Shared Understanding Gate, Ticket Promotion

## Constraints

- Product constraints from the PRD:
  - `/ldd:research` must gather standard PM inputs before PRD scoping and must not itself scope, design, plan, or implement.
  - Research must have full read-only repo and local context visibility.
  - Shareable research output must separate evidence, codebase facts, constraints, assumptions, risks, sensitivity handling, and open questions.
  - Each LDD phase must declare and enforce an input-quality standard before writing or mutating artifacts.
  - Weak input must be rejected with the missing quality bar and the earliest command that can fix it.
  - Sensitive private inputs may inform research but must be sanitized before entering committed artifacts or GitHub projections.
- Technical constraints from existing code:
  - LDD commands are standalone command-shaped skills, not a shared runtime.
  - Adapter files are routers; `skills/ldd-*/SKILL.md` files are canonical.
  - The repo-local `ledger.yml` is canonical phase state.
  - `.ldd/templates/*` are installed copies sourced from `skills/ldd-setup/assets/templates/*`.
  - `scripts/validate-ldd-mvp.sh` is the package-level contract test.
- Operational constraints:
  - GitHub is an optional projection, and external mutations require human confirmation.
  - Installed Codex skills are local copies, so package changes must be reflected in source manifests and setup templates.
- Compatibility constraints:
  - Existing ledgers without research fields must still be readable.
  - Local tracker mode continues to use local IDs; GitHub tracker mode continues to use GitHub issue numbers as approved ticket IDs.
- Explicit non-goals:
  - No Linear or Jira mutation behavior.
  - No centralized runtime engine or schema migration tool.
  - No storage of raw private research inputs in tracked repo artifacts.

## Existing System

The package is a collection of standalone skills. Each command owns its workflow contract in `skills/ldd-*/SKILL.md`, with Claude and Gemini adapter files pointing back to the canonical skill. The top-level `agent-skills.json`, `.claude-plugin/plugin.json`, and `gemini-extension.json` list the available command surface.

Current PRD creation moves through `/ldd:scope`, `/ldd:elaborate`, `/ldd:refine`, and `/ldd:approve`. Scope, elaborate, and refine currently use bounded shared-understanding gates, but there is no first-class research phase before scope and no uniform phase input-gate contract across all commands. `/ldd:scope` explicitly avoids reading the codebase as design input, while `/ldd:design` is allowed to read code and ADRs.

The ledger template tracks PRD, SDD, plan, implementation, verification, child tickets, closure, execution context, sync state, and events. It has no research artifact field today. Because the ledger is YAML consumed by humans and agents rather than strict generated code, optional additive fields are compatible with existing tickets.

GitHub projection support now treats PRD approval as GitHub issue creation or binding in GitHub tracker mode. SDD approval creates a child SDD issue referencing the PRD issue, and decomposition creates implementation issues referencing the SDD issue.

## Decision Summary

| Decision | Rationale | Source |
| --- | --- | --- |
| Add `/ldd:research` as a standalone command-shaped skill with the same adapter surfaces as other commands. | The package model has no shared command runtime; adding a normal skill preserves the existing installation and adapter pattern. | PRD / code |
| Model research as an optional ledger artifact: `artifacts.research.path` and `artifacts.research.status`. | Research must become durable enough to hand off to scope, while existing tickets without research must keep working. | PRD / code |
| Keep raw sensitive PM inputs out of committed artifacts; store only sanitized conclusions, source classes, and redaction notes in `research.md`. | The PRD explicitly permits private inputs but excludes sensitive material from GitHub and tracked artifacts. | PRD |
| Allow `/ldd:research` full read-only code visibility, but keep `/ldd:scope`, `/ldd:elaborate`, and `/ldd:refine` in the PM boundary. | Research needs code visibility to inform readiness; PM commands should still avoid technical design and solution-smuggling. | PRD / existing skill rules |
| Add an "Input Quality Gate" section to every command skill. | The current quality gates are command-specific and uneven; the PRD requires similar controls at each phase. | PRD |
| Make scope refuse weak inputs before writing PRD scope and route to `/ldd:research` when PM-grade inputs are missing. | Scope is the earliest PRD mutation point and must not create plausible artifacts from inadequate evidence. | PRD |
| Extend validation to require the new research command, adapters, manifest entries, setup templates, and gate language. | `scripts/validate-ldd-mvp.sh` is the current package contract test and should catch incomplete command-surface changes. | code |
| Do not create an ADR for this change. | This extends the existing command-contract and ledger-template model without changing the durable architecture rule that repo-local ledger is canonical. | code |

## Alternatives Considered

| Alternative | Why not | Tradeoff accepted |
| --- | --- | --- |
| Fold research into `/ldd:scope`. | The PRD needs research to gather broad inputs and code facts before scope decides product boundaries. Scope would become too broad and would blur PM/product discovery with scoping. | One more command is added to the workflow. |
| Create a shared gate engine or reusable rule file. | LDD skills are intentionally standalone so each agent can execute a command from its own skill file without resolving shared code. | Gate wording is duplicated across skills, checked by validation. |
| Persist raw PM research notes in a gitignored `.ldd/private/` convention. | The PRD only requires consuming private context, not creating a local secret store. Introducing storage rules would expand scope and increase handling risk. | The research contract tells the agent to use private inputs transiently or from human-managed local files, then commit only sanitized output. |
| Make research mandatory for every PRD. | Some inputs may already meet the PRD handoff bar, and `/ldd:scope` can validate adequacy directly. | Research is strongly routed when quality is insufficient, but not an unconditional step. |
| Put GitHub SDD and child hierarchy changes in this feature. | The core hierarchy contract already exists in approve/decompose behavior and templates. This feature should validate that integration and avoid reopening settled design. | Implementation will add validation coverage where needed, not redesign GitHub projection. |

## Proposed Design

### New `/ldd:research` Command

Add a new standalone skill at `skills/ldd-research/SKILL.md`, plus:

- `skills/ldd-research/agents/openai.yaml`
- `commands/ldd/research.md`
- `commands/ldd/research.toml`
- manifest entries in `agent-skills.json`, `.claude-plugin/plugin.json`, and `gemini-extension.json`
- README/GEMINI references

The research command owns product discovery inputs only:

- source trigger or request
- target users/personas
- problem evidence
- current workflow
- desired outcome
- product importance
- constraints
- prior context
- comparable behavior
- candidate non-goals
- open questions
- codebase facts relevant to product readiness
- sensitivity classification and sanitization notes

It explicitly does not own goals, non-goals, user stories, acceptance criteria, metrics, software design, plans, decomposition, implementation, verification, or closure.

Research output is `research.md` in the draft or promoted ticket directory. Add `skills/ldd-setup/assets/templates/research.md`, and install it as `.ldd/templates/research.md`. The template should include:

- Research Summary
- Expected PM Inputs
- Evidence
- Current Workflow
- Users / Stakeholders
- Desired Outcomes
- Constraints
- Codebase Facts
- Assumptions
- Risks
- Sensitivity Handling
- Open Questions
- Readiness Decision

Readiness decision values:

- `ready_for_scope`
- `blocked_on_more_input`
- `split_recommended`
- `not_a_product_requirement`

### Ledger Changes

Extend the setup ledger template additively:

```yaml
artifacts:
  research:
    path: null
    status: missing
```

Research writes set:

```yaml
artifacts:
  research:
    path: "docs/tickets/_drafts/<draft-id>/research.md"
    status: ready_for_scope | blocked | split_recommended | not_product_requirement
execution_context:
  phase: research
  current_gate: research
  next_command: /ldd:scope <draft-id>
  next_human_action: null
```

Existing ledgers remain valid when `artifacts.research` is absent. Commands must treat a missing research artifact as "not performed", not as corruption.

### Phase Input Gates

Each command skill gets a named `Input Quality Gate` before its write rules. The gate must state:

- required inputs for that phase
- how to validate they are sufficient
- what artifact or ledger state is required
- what to do when input is insufficient
- earliest command that can repair the gap

Minimum phase gates:

| Command | Required input standard | Reject to |
| --- | --- | --- |
| `/ldd:research` | A product trigger or context source, plus enough human-accessible context to investigate. | Human question for source/context. |
| `/ldd:scope` | Clear problem or desired outcome, target user or workflow, constraints/non-goal candidates, and either research readiness or equivalent supplied inputs. | `/ldd:research` or one decisive missing-input question. |
| `/ldd:elaborate` | Scoped goals/non-goals and enough user/problem detail to map stories and product outcomes. | `/ldd:scope` or `/ldd:research`. |
| `/ldd:refine` | Elaborated PRD with goals, stories, acceptance criteria, metrics, dependencies, and owned open questions. | `/ldd:elaborate` or `/ldd:scope`. |
| `/ldd:approve` | Exactly one active PRD, SDD, or plan approval gate and the relevant artifact passing its checklist. | Owning phase command. |
| `/ldd:design` | Approved PRD, readable code/ADR context, and no product contradiction. | `/ldd:refine`, `/ldd:scope`, or `/ldd:research` depending on the gap. |
| `/ldd:plan` | Approved SDD and PRD, with no new architecture decision discovered during planning. | `/ldd:design`. |
| `/ldd:decompose` | Approved plan with traceable vertical slices and, in GitHub mode, an approved/bound SDD issue. | `/ldd:plan` or `/ldd:approve`. |
| `/ldd:implement` | Ready child ticket with approved parent PRD, SDD, and plan boundaries. | `/ldd:decompose` or parent planning/design command. |
| `/ldd:verify` | Implemented child ticket plus explicit verification scope and approved parent boundaries. | `/ldd:implement` or owning parent command for drift. |
| `/ldd:close` | Passed verification for child closure, or all children verified and closeable for parent closure. | `/ldd:verify` or `/ldd:next`. |
| `/ldd:next` | Readable ledger state, or derivable state from artifacts. | Human reconciliation when state is ambiguous. |
| `/ldd:setup` | Target repo context and confirmed tracker settings on rerun. | Human confirmation for setup choices. |

The reject response must name the missing quality bar, avoid mutating the artifact, and print a copyable next command when there is one.

### Scope Changes

`/ldd:scope` becomes the first mutation gate for PRDs. Before creating or updating scope, it must determine whether input is PM-grade enough:

- If research exists and is `ready_for_scope`, scope may proceed using the sanitized research output.
- If research exists and is blocked, split-recommended, or not a product requirement, scope must reject and report that decision.
- If no research exists but the user supplied equivalent context, scope may proceed while recording assumptions.
- If no research exists and the problem/outcome/users/evidence are weak, scope must route to `/ldd:research`.

Scope still must not read the codebase as a design input. It may consume codebase facts already summarized by research as product constraints, dependencies, or open questions.

### Privacy Boundary

Research can inspect the full repository and any human-supplied local/private context, but it must classify source sensitivity before writing:

- Public/shareable: may be summarized normally.
- Internal/private: summarize only conclusions needed for product decisions.
- Financially sensitive or secret: do not quote, copy, or identify raw values; record only sanitized implications and a redaction note.

Committed artifacts and GitHub issue bodies must be safe to share with the configured external tracker audience. If sanitization cannot preserve enough information to justify the PRD, research must block and ask the human for a shareable summary or approval to proceed with explicit assumptions.

### GitHub Projection Validation

This feature does not change the approved GitHub hierarchy design. It validates that:

- PRD approval in GitHub tracker mode uses the GitHub issue number as the ticket ID.
- SDD approval creates or binds an SDD issue that references the PRD issue.
- Decomposition creates implementation child issues that reference the SDD issue.
- External issue bodies use sanitized PRD/SDD/child content only.

Any new research content must not be projected to GitHub unless later PRD/SDD artifacts already contain the sanitized conclusions.

## Data Flow / Control Flow

1. Research path:
   - Human runs `/ldd:research` with a trigger or context.
   - Agent reads repo/docs/artifacts and any human-supplied private context.
   - Agent classifies sensitivity, writes sanitized `research.md`, updates optional research ledger fields, and routes to `/ldd:scope` only when ready.
2. Scope path with research:
   - Human runs `/ldd:scope`.
   - Scope checks for `artifacts.research.status`.
   - If ready, it consumes `research.md` as input and writes only scope-owned PRD sections.
   - If absent but equivalent context is present, it may proceed with assumptions.
3. Scope rejection path:
   - Scope detects missing problem, user/workflow, evidence, or outcome.
   - Scope writes nothing, states the missing standard, and routes to `/ldd:research`.
4. Later phase gate path:
   - A command reads ledger/artifact state before mutation.
   - If input does not meet the phase gate, it writes nothing and routes to the earliest command that can repair the issue.
5. GitHub path:
   - Approval/decomposition commands continue to perform external mutations only after explicit human confirmation and drift checks.

## Interfaces / Contracts

| Contract | Producer | Consumer | Compatibility notes |
| --- | --- | --- | --- |
| `/ldd:research [new|draft-id|ticket-id] [context]` | Skill package | Human/agent adapters | New command; no existing callers break. |
| `research.md` | `/ldd:research` | `/ldd:scope`, humans | New optional artifact; sanitized and commit-safe. |
| `artifacts.research.path/status` | `/ldd:research`, setup template | `/ldd:scope`, `/ldd:next` | Optional field; missing means research was not run. |
| Research readiness labels | `/ldd:research` | `/ldd:scope` | Labels are command contract values, not GitHub labels. |
| Input Quality Gate sections | All command skills | Human/agent executor, validation script | Markdown contract enforced by validation greps and review. |
| Adapter command entries | `agent-skills.json`, Claude/Gemini manifests | Codex/Claude/Gemini installers | Must be updated together with the new skill. |
| GitHub SDD/child hierarchy | `/ldd:approve`, `/ldd:decompose` | GitHub issue projection | Existing contract remains; validation may be strengthened. |

## Migration / Compatibility

- Migration required: none for existing tickets. `artifacts.research` is optional.
- Rollout/backout: adding the research command is additive. Backout removes the command surface and optional template without changing existing approved tickets.
- Default behavior: `/ldd:scope` can still proceed without research when supplied context meets the PM-grade input bar.
- Compatibility tests:
  - Existing promoted ticket with no `artifacts.research` remains readable by `/ldd:next` and later commands.
  - New setup installs research template and ledger field.
  - Manifests list `/ldd:research` consistently for Codex, Claude, and Gemini.

## Observability

- Logs: no runtime logging layer exists; command output must report gate decisions and artifact paths.
- Metrics: no automated telemetry.
- Alerts: not applicable.
- Debugging affordances:
  - Ledger events should include `research_completed` or `research_blocked`.
  - `research.md` should contain the readiness decision and redaction notes.
  - `/ldd:next` should surface the next command in a copyable command block.
  - Validation script should fail when the research command surface or input gate language is incomplete.

## Security / Privacy

- Data touched:
  - Repository source, docs, tickets, setup templates, adapter manifests.
  - Optional human-supplied private PM context during research.
- Permissions/authz:
  - Research is read-only over code and local context.
  - External tracker mutation remains limited to commands that explicitly own GitHub projection and have human confirmation.
- Secrets:
  - Research must not write secrets, financial values, private customer data, or raw confidential notes into `research.md`, PRDs, SDDs, plans, GitHub issues, or PR bodies.
- Abuse cases:
  - A pasted sensitive context dump could accidentally be copied into committed research output. Mitigation: sensitivity classification before writing and explicit redaction notes.
  - Scope could bypass research and create weak PRDs. Mitigation: scope input gate and rejection path.
  - GitHub projection could leak research details. Mitigation: only sanitized downstream artifacts are projected.

## ADRs

- Existing: none.
- New: none.

ADR threshold not met. The design extends the existing standalone command and repo-local ledger contract. It does not introduce a new durable architecture rule, ownership boundary, or external source of truth.

## Open Design Questions

| Question | Impact | Owner | Next action |
| --- | --- | --- | --- |
| None blocking. | Planning can proceed. | Agent | Use this SDD to build implementation slices. |

## Review Checklist

- [x] Every material PRD goal has a corresponding design decision or explicit non-design note.
- [x] The design is grounded in current code and relevant ADRs.
- [x] No product scope has been added beyond the PRD.
- [x] New architectural decisions have ADRs or are clearly below the ADR threshold.
- [x] Interfaces, migration, observability, and security/privacy have been considered.
- [x] Open questions are either resolved or explicitly block plan approval.
