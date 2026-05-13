# Local Ledger MVP Design

**Date:** 2026-05-12
**Status:** MVP scope

## Thesis

Ledger-Driven Development uses a repo-local ledger as canonical workflow state. External trackers such as GitHub, Linear, and Jira are optional sync and review surfaces, not the source of truth for LDD state.

The MVP keeps this deliberately narrow: one Product Requirement moves through the full SDLC flow, then decomposes into child vertical-slice tickets for implementation and verification. Sync engines, deep child lifecycle management, and swarm orchestration are out of scope.

## Package Source Of Truth

This repository publishes command-shaped agent skills. The repo-root `agent-skills.json` file is the package manifest for installable skills and adapter manifests.

Installed skills are copies in an agent-specific local directory. They are not live-linked to this repository. Updating an installed LDD skill set means reinstalling the skills listed in `agent-skills.json` and restarting the agent.

There is no installed `ldd-core` skill in the MVP. Shared LDD rules live inside each command-shaped skill so `/ldd:*` commands remain self-contained across Codex, Claude, Gemini, and other agents.

LDD must not depend on other installed skills. Commands may be inspired by known workflows, but the command-shaped LDD skill must include the required instructions itself. In particular, `/ldd:implement` embeds its own red/green/refactor loop.

## Canonical Terms

See `CONTEXT.md` for the glossary. The key terms are:

- **Ledger**: repo-local machine-readable state for one ticket.
- **Product Requirement**: the parent product-scope unit.
- **Draft Ticket Directory**: temporary workspace before a ticket ID is assigned.
- **Ticket Promotion**: assignment of a stable local or external ticket ID.
- **Decomposition**: conscious post-plan step that turns an approved plan into vertical slices.
- **Workflow Navigation**: read-only identification of the next LDD command.
- **Verification**: child-work closure gate after implementation.

## Directory Model

Every Product Requirement starts as a draft:

```text
docs/tickets/_drafts/YYYY-MM-DD-short-slug/
  ledger.yml
  prd.md
```

Promotion assigns a stable ticket ID and moves the directory:

```text
docs/tickets/LDD-0001/
  ledger.yml
  prd.md
  sdd.md
  plan.md
  plan.html
  children/
```

If an external tracker is configured, promotion may create or bind to an external ID such as `PROJ-123` and use that as the promoted directory name.

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
  current_gate: prd_approval
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

/ldd:scope
/ldd:elaborate
/ldd:refine
  -> build the PRD in a draft directory
  -> refine promotes the draft to a stable ticket ID when approved

/ldd:design
  -> writes SDD for the promoted Product Requirement

/ldd:plan
  -> writes reviewed implementation plan and plan.html

/ldd:decompose
  -> turns approved plan slices into child vertical-slice tickets

/ldd:implement
  -> implements one ready child ticket

/ldd:verify
  -> verifies implemented child-ticket closure readiness
  -> recommends human-approved archive/external close only after evidence passes
```

`/ldd:next` is read-only. It inspects active ledgers, identifies the next command, explains why, and stops.

`/ldd:implement` never auto-decomposes. If no ready child tickets exist, it reports that there are no tickets to implement. If the plan is approved but no child tickets exist, it reports that `/ldd:decompose` is required. Implementation completion does not close child work; it records evidence and routes the child to `/ldd:verify`.

`/ldd:verify` is the child-ticket closure gate. It checks implementation evidence, required checks, traceability to the approved PRD/SDD/plan, and external drift metadata. It writes `verification.md` and machine-readable ledger status. It may recommend closure, but archive and external close still require human confirmation.

## External Trackers

External trackers are configured through `.ldd/config.yml`. The MVP supports the model, not full sync engines:

- `local`: use `LDD-0001` style local IDs.
- `github`, `linear`, `jira`: promotion may bind to an externally assigned ID.

External mutations require human confirmation. If local ledger state and external tracker state diverge, commands report drift and stop rather than silently reconciling.

The MVP supports the state model for external IDs, but does not promise a full sync engine. A GitHub, Linear, or Jira integration can be tested as a thin promotion/binding path without making that tracker canonical.

External tracker tickets are rich projections, not thin placeholders. A TPM, PM, Director, or implementation agent must be able to read the external ticket without opening the repository and understand the product requirement or child work item.

Parent Product Requirement tickets use `.ldd/templates/issue-body-prd.md` and include the PRD problem, goals, non-goals, users, user stories, acceptance criteria, success metrics, dependencies, open questions, and LDD links.

Child work item tickets use `.ldd/templates/issue-body-child.md` and intentionally stay lightweight: Parent, What to build, Acceptance criteria, Blocked by, User stories covered, and minimal LDD traceability.

`/ldd:decompose` must preview the complete proposed child ticket set before creation. The preview includes title, Autonomous/Human-review type, blockers, user stories covered, and summary. External child tickets are created only after human approval.

External tickets can evolve through comments or body edits. LDD records sync metadata such as last checked time, external update time, managed body version, and body hash. If an external body changed since the last sync, commands report drift and stop for human reconciliation.

## Out of Scope

- full GitHub/Linear/Jira sync engines
- automatic external tracker reconciliation
- swarm orchestration
- deep child ticket lifecycle beyond planned/ready/implemented/verification_required/verified/archive
- global ledger files
- progress.md-style session tracking
