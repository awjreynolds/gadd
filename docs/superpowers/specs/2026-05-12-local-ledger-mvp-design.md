# Local Ledger MVP Design

**Date:** 2026-05-12
**Status:** MVP scope

## Thesis

Ledger-Driven Development uses a repo-local ledger as canonical workflow state. External trackers such as GitHub, Linear, and Jira are optional sync and review surfaces, not the source of truth for LDD state.

The MVP keeps each Product Requirement deliberately narrow: one Product Requirement moves through the full SDLC flow, then decomposes into child vertical-slice tickets for implementation and verification. Repositories may contain multiple active Product Requirements at different phases. Sync engines, deep child lifecycle management, and swarm orchestration are out of scope.

## Package Source Of Truth

This repository publishes command-shaped agent skills. The repo-root `agent-skills.json` file is the package manifest for installable skills and adapter manifests.

Installed skills are copies in an agent-specific local directory. They are not live-linked to this repository. Updating an installed LDD skill set means reinstalling the skills listed in `agent-skills.json` and restarting the agent.

There is no installed `ldd-core` skill in the MVP. Shared LDD rules live inside each command-shaped skill so `/ldd:*` commands remain self-contained across Codex, Claude, Gemini, and other agents.

LDD must not depend on other installed skills. Commands may be inspired by known workflows, but the command-shaped LDD skill must include the required instructions itself. In particular, `/ldd:implement` embeds its own red/green/refactor loop.

## Canonical Terms

See `CONTEXT.md` for the glossary. The key terms are:

- **Ledger**: repo-local machine-readable state for one ticket.
- **Product Requirement**: the parent product-scope unit.
- **Research Artifact**: sanitized pre-scope PM input, codebase fact, risk, sensitivity, and readiness evidence.
- **Input Quality Gate**: a command-local input standard checked before artifact mutation.
- **Draft Ticket Directory**: temporary workspace before a ticket ID is assigned.
- **Ticket Promotion**: assignment of a stable local or external ticket ID.
- **Decomposition**: conscious post-plan step that turns an approved plan into vertical slices.
- **Workflow Navigation**: read-only identification of the next LDD command.
- **Verification**: child-work closure gate after implementation.
- **Bounded Shared Understanding Gate**: Product Manager checkpoint that proves shared understanding without expanding the current PRD.
- **GitHub-first Projection**: GitHub issues and PRs as the first external tracker visibility path, while the repo-local ledger remains canonical.

## Directory Model

Every Product Requirement starts as a draft:

```text
docs/tickets/_drafts/YYYY-MM-DD-short-slug/
  ledger.yml
  prd.md
```

An incomplete promoted ticket does not block a new draft. `/ldd:scope` may create a new draft while other promoted tickets remain active, but local mode keeps at most one active draft in `_drafts/` to avoid ambiguous Product Manager work.

Promotion assigns a stable ticket ID and moves the directory. Local mode uses the configured local prefix:

```text
docs/tickets/LDD-0001/
  ledger.yml
  prd.md
  sdd.md
  plan.md
  plan.html
  children/
```

If GitHub is configured, PRD approval creates or binds the GitHub Product Requirement issue first, then uses the GitHub issue number as the stable ticket ID and promoted directory name, for example `docs/tickets/123-short-slug/`.

Completed child work items move to:

```text
docs/tickets/_archive/<child-id>/
```

Normal workflow navigation ignores `_archive/`.

## Ledger MVP Schema

`ledger.yml` is intentionally small:

```yaml
schema_version: 1

ticket:
  id: null
  draft_id: 2026-05-12-short-slug
  title: Short title
  kind: product_requirement
  status: draft

tracker:
  mode: local
  external_id: null
  external_url: null

artifacts:
  research:
    path: null
    status: missing
  prd:
    path: docs/tickets/_drafts/2026-05-12-short-slug/prd.md
    status: draft
  sdd:
    path: null
    status: missing
  plan:
    path: null
    status: missing
  implementation:
    status: not_started
  verification:
    path: null
    status: missing

children: []

execution_context:
  phase: scope
  current_gate: scope
  next_command: /ldd:elaborate
  next_human_action: null
  next_reason: Draft Product Requirement exists and needs elaboration before approval.

closure:
  status: open
  verified_at: null

sync:
  status: local_only
  last_checked_at: null

events:
  - at: 2026-05-12T10:00:00Z
    type: draft_created
    actor: human
```

Events are important workflow transitions only. They are not progress logs or session traces.

## Command Flow

```text
/ldd:setup
  -> installs config, templates, draft/archive directories

/ldd:research
  -> gathers PM-grade inputs, codebase facts, and sanitized readiness evidence
  -> routes to /ldd:scope only when ready_for_scope

/ldd:scope
/ldd:elaborate
/ldd:refine
  -> build the PRD in a draft directory
  -> refine routes PRD approval to /ldd:approve

/ldd:approve
  -> approves a PRD, SDD, or plan gate when exactly one approval gate is active
  -> does not approve decomposition, closure, or external mutations

/ldd:design
  -> writes SDD for the promoted Product Requirement
  -> routes SDD approval to /ldd:approve

/ldd:plan
  -> writes reviewed implementation plan and plan.html

/ldd:decompose
  -> turns approved plan slices into child vertical-slice tickets

/ldd:implement
  -> implements one ready child ticket

/ldd:verify
  -> verifies implemented child-ticket closure readiness
  -> recommends human-approved close only after evidence passes

/ldd:close
  -> applies closure for one verified child ticket or a closeable parent roll-up
  -> keeps local ticket paths stable and syncs external close only with explicit human approval

/ldd:archive
  -> optional local storage cleanup for already-closed tickets
```

`/ldd:next` is read-only. It inspects active ledgers, identifies the next command and next human action, explains why, and stops. For PRD, SDD, and plan approval gates, it names `/ldd:approve <ticket-id>`.

`/ldd:research` is the pre-scope discovery command. It may use full read-only visibility into repository files, docs, existing artifacts, and human-supplied private/local context, but it writes only sanitized committed output. Its readiness decision is one of `ready_for_scope`, `blocked_on_more_input`, `split_recommended`, or `not_a_product_requirement`.

`/ldd:scope` is the draft entry point for new Product Requirements. If no active draft exists, it creates a new draft in `docs/tickets/_drafts/`. Existing promoted tickets do not block new scoping work. If an active draft already exists, `/ldd:scope` updates that draft or asks the human to continue, rename, promote, or discard it before starting another one.

Every command-shaped skill owns an `Input Quality Gate`. Before writing or mutating artifacts, the command validates that its source inputs meet the phase standard. Rejections name the missing input and the earliest LDD command that can repair it, rather than filling gaps from assumptions.

`/ldd:implement` never auto-decomposes. If no ready child tickets exist, it reports that there are no tickets to implement. If the plan is approved but no child tickets exist, it reports that `/ldd:decompose` is required. Implementation completion does not close child work; it records evidence and routes the child to `/ldd:verify`.

`/ldd:verify` is the child-ticket closure-readiness gate. It checks implementation evidence, required checks, traceability to the approved PRD/SDD/plan, and external drift metadata. It writes `verification.md` and machine-readable ledger status. It may recommend closure, but it does not archive or close external tickets.

`/ldd:close` is the post-verification mutating gate. For a child ticket, it requires passed verification, records workflow closure, updates parent ledger state, and closes or syncs external tracker projections only with explicit human confirmation. It does not move local ticket files. For a parent ticket, it may close the parent only when every child is already closed or verified and closeable; otherwise it stops with the blocking child list.

`/ldd:archive` is optional storage hygiene for already-closed tickets. It moves local ticket packages to `_archive/` and rewrites local paths, but it never decides whether work is done and never mutates external trackers.

## External Trackers

External trackers are configured through `.ldd/config.yml`. The MVP supports the model, not full sync engines:

- `local`: use `LDD-0001` style local IDs.
- `github`: first external tracker dogfooding path, using GitHub issue numbers as ticket IDs for PRD, SDD, and child work visibility, GitHub native sub-issues for child work hierarchy where supported, and GitHub PRs for implementation review.
- `linear`, `jira`: follow-on optional collaboration surfaces after the GitHub-first projection model is proven.

External mutations require human confirmation. If local ledger state and external tracker state diverge, commands report drift and stop rather than silently reconciling.

The MVP supports the state model for external IDs, but does not promise a full sync engine. GitHub projections can be dogfooded first without making GitHub canonical; Linear and Jira should not be treated as parity requirements yet.

External tracker tickets are rich projections, not thin placeholders. A TPM, PM, Director, or implementation agent must be able to read the external ticket without opening the repository and understand the product requirement, SDD review context, or child work item.

Parent Product Requirement tickets use `.ldd/templates/issue-body-prd.md` and include the PRD problem, goals, non-goals, users, user stories, acceptance criteria, success metrics, dependencies, open questions, and LDD links.

SDD tickets use `.ldd/templates/issue-body-sdd.md` and reference the parent PRD issue. Child work item tickets use `.ldd/templates/issue-body-child.md` and intentionally stay lightweight: Parent, What to build, Acceptance criteria, Blocked by, User stories covered, and minimal LDD traceability. In GitHub mode, decomposition-created child work issues must be attached as native sub-issues of the SDD issue when GitHub supports sub-issues, with body traceability as backup. That makes implementation work children of the SDD issue and grandchildren of the PRD issue in the external projection.

`/ldd:decompose` must preview the complete proposed child ticket set before creation. The preview includes title, Autonomous/Human-review type, blockers, user stories covered, and summary. External child tickets are created only after human approval.

External tickets can evolve through comments or body edits. LDD records sync metadata such as last checked time, external update time, managed body version, and body hash. If an external body changed since the last sync, commands report drift and stop for human reconciliation.

## Out of Scope

- full GitHub/Linear/Jira sync engines
- automatic external tracker reconciliation
- swarm orchestration
- deep child ticket lifecycle beyond planned/ready/implemented/verification_required/verified/archive
- global ledger files
- progress.md-style session tracking
