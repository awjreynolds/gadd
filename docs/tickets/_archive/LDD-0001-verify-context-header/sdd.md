---
ticket: LDD-0001
prd: docs/tickets/_archive/LDD-0001-verify-context-header/prd.md
created: 2026-05-13
updated: 2026-05-13
adrs: []
---

# Software Design Document: Add LDD execution context and verification gate

## Context

This design implements the approved PRD for `LDD-0001`. The existing MVP already has command-shaped skills, repo-local per-ticket ledgers, rich issue templates, and a local archive directory. It does not yet expose a compact execution context/header for a ticket, and it does not yet have a separate verification gate between implementation completion and ticket closure.

- PRD: `docs/tickets/_archive/LDD-0001-verify-context-header/prd.md`
- Existing entry points:
  - `skills/ldd-*/SKILL.md`
  - `commands/ldd/*.md`
  - `commands/ldd/*.toml`
  - `agent-skills.json`
  - `.claude-plugin/plugin.json`
  - `gemini-extension.json`
  - `scripts/validate-ldd-mvp.sh`
- Relevant ADRs: none. No ADR directory exists yet.
- Terms from the codebase/domain glossary: Ledger, Product Requirement, Child Work Item, Vertical Slice, Workflow Navigation, Standalone Skill Contract, External Drift, Ticket Archive.

## Constraints

- Product constraints from the PRD:
  - LDD remains local-ledger-first.
  - The context/header must work before, during, and after SDD creation; it cannot be owned only by the SDD.
  - Verification is specific to child-ticket closure, not a general repository healthcheck.
  - Implementation completion and ticket closure are separate states.
  - The feature must be standalone and agent-agnostic.
- Technical constraints from existing code:
  - Every installed command must carry its own workflow contract; there is no shared installed `ldd-core`.
  - Adapter files are thin routers and must continue to point to canonical `skills/ldd-*/SKILL.md` files.
  - `scripts/validate-ldd-mvp.sh` explicitly enumerates commands and package files.
  - Setup templates under `skills/ldd-setup/assets/templates/` are copied into target repos and must be updated with any new ledger/artifact contract.
- Operational constraints:
  - External tracker mutation requires human confirmation.
  - Existing repos may have ledgers without the new context or verification fields.
- Compatibility constraints:
  - Commands must tolerate missing new fields and derive state from existing artifact statuses where possible.
  - Existing `docs/tickets/_archive/` behavior stays unchanged: normal workflow navigation ignores archived child work.
- Explicit non-goals:
  - No general repository healthcheck.
  - No full external tracker sync engine.
  - No multi-agent orchestration or swarm executor.
  - No global ledger.
  - No `progress.md`.

## Existing System

- Current flow:
  - `/ldd:setup` installs config, templates, and ticket directories.
  - `/ldd:scope`, `/ldd:elaborate`, and `/ldd:refine` create and approve a Product Requirement.
  - `/ldd:design` writes this SDD.
  - `/ldd:plan` writes `plan.md` and `plan.html`.
  - `/ldd:decompose` creates independently grabbable child work items from an approved plan.
  - `/ldd:implement` executes one ready child work item using its built-in TDD loop.
  - `/ldd:next` reads ledgers and reports the next command.
- Current data/contracts:
  - `ledger.yml` records ticket identity, artifact paths/statuses, child links, sync state, and compact events.
  - `issue-body-prd.md` and `issue-body-child.md` are rich external projections.
  - `pr-body-implementation.md` captures implementation conformance but does not decide closure.
- Extension points:
  - New command-shaped skills can be added by creating `skills/ldd-verify/`, adapter files, agent metadata, and manifest entries.
  - Ledger schema can be extended because commands already treat the repo-local ledger as canonical.
  - Templates can be expanded for new target repos.
- Fragile or risky areas:
  - Command lists are duplicated in manifests, adapters, README, Gemini/Claude metadata, and validation.
  - `/ldd:next` currently does not model verification-required states.
  - `/ldd:implement` currently says it updates ledgers after approval, but it does not define a closure gate.
- Prior art to follow:
  - The current ledger keeps workflow state compact and machine-readable.
  - Decomposition previews child tickets before creation.
  - Implementation embeds its own TDD loop instead of depending on an external skill.

## Decision Summary

| Decision | Rationale | Source |
| --- | --- | --- |
| Add an `execution_context` section to each ticket ledger rather than a separate context file. | The PRD rejects global state and says the context cannot be owned only by the SDD. The existing ledger is already the canonical per-ticket state and avoids another artifact to keep synchronized. | PRD, `CONTEXT.md`, local ledger MVP design |
| Add `/ldd:verify` as a standalone command-shaped skill. | Verification is a distinct gate between implementation completion and closure. Folding it into `/ldd:implement` would hide the human closure boundary. | PRD |
| Store verification results as `verification.md` plus ledger status fields on child work items. | Reviewers need readable output, while workflow navigation needs machine-readable status. | PRD, existing artifact pattern |
| Keep closure/archive/external close separate from verification pass. | The PRD requires implementation completion, verification, and closure to be distinct. Verification can recommend closure, but external mutation and archive still require human approval. | PRD, existing external mutation rule |
| Update `/ldd:next` to prioritize verify-required child work before additional implementation. | Maintainers need the next gate visible without reconstructing chat history. | PRD |
| Do not create an ADR for this design. | The choices extend the existing ledger-first architecture rather than changing ownership boundaries or introducing a surprising cross-cutting rule. | SDD template ADR threshold |

## Alternatives Considered

| Alternative | Why not | Tradeoff accepted |
| --- | --- | --- |
| Separate `context.yml` per ticket. | It creates a second canonical state surface and increases drift risk with `ledger.yml`. | The ledger grows slightly, but remains the single machine-readable ticket state. |
| Put execution context only in SDD frontmatter. | The PRD says context must be usable before, during, and after SDD creation. SDD-only context would not help early phases or child tickets. | SDDs stay focused on engineering design. |
| Treat verification as part of `/ldd:implement`. | That would collapse implementation completion and closure verification into one phase. | A new command adds package surface but preserves the gate. |
| Add a general `/ldd:healthcheck`. | The PRD explicitly excludes a broad repository healthcheck. | Verification remains narrower and easier to test. |
| Auto-close/archive after verification passes. | External mutations and archive decisions require human confirmation. | Passing verification still needs a short approval step before closure. |

## Proposed Design

### New or changed responsibilities

- `ledger.yml`
  - Gains an `execution_context` section for compact, current handoff state.
  - Child ledgers gain verification and closure fields.
- `/ldd:next`
  - Reads `execution_context` when present.
  - Derives context from artifact statuses when the field is absent.
  - Reports `/ldd:verify <child-ticket-id>` when implementation is complete but closure is not verified.
- `/ldd:implement`
  - Continues to implement one ready child work item.
  - On completed implementation evidence, marks implementation complete and closure verification required.
  - Does not archive or externally close child work.
- `/ldd:verify`
  - Reads the child ledger, parent ledger, approved PRD, approved SDD, approved plan, child ticket body, implementation evidence, check evidence, and external drift metadata.
  - Writes `verification.md` in the child ticket directory.
  - Updates child ledger verification status to `passed`, `failed`, or `override_required`.
  - Recommends closure only when evidence, checks, traceability, and drift checks pass.
- `/ldd:setup`
  - Copies updated ledger and verification templates into target repos.
- Package manifests and adapters
  - Add `ldd-verify` wherever other command-shaped skills are listed.

### State/data changes

Parent and child ledgers support this optional section:

```yaml
execution_context:
  phase: design | plan | decompose | implement | verify | done
  current_gate: prd_approval | design_review | plan_review | decomposition_review | implementation | verification | closure
  next_command: /ldd:design
  next_human_action: null
  next_reason: PRD is approved and SDD is missing.
  approved_artifacts:
    prd: docs/tickets/_archive/LDD-0001-verify-context-header/prd.md
    sdd: null
    plan: null
  boundaries:
    product: docs/tickets/_archive/LDD-0001-verify-context-header/prd.md
    design: null
    plan: null
  updated_at: 2026-05-13T00:00:00Z
```

Child ledgers additionally support:

```yaml
artifacts:
  verification:
    path: docs/tickets/LDD-0001/children/LDD-0001-001/verification.md
    status: missing | pending | passed | failed | overridden

closure:
  status: open | verification_required | verified | archived | externally_closed
  verified_at: null
  archived_at: null
  external_closed_at: null
  override_reason: null
```

Existing ledgers without these fields remain valid. Commands derive equivalent context from `ticket.status`, artifact statuses, `children`, and sync state.

### Boundary changes

- Product Requirement closure remains out of scope for the MVP except for parent roll-up visibility from child states.
- Verification operates on child work items, not parent PRDs.
- External trackers remain projections; verification reads drift metadata and blocks closure if drift is unresolved, but it does not reconcile external changes.

### Error handling

- Missing implementation evidence: `/ldd:verify` writes a failed verification report and leaves `closure.status` as `verification_required`.
- Failed checks: `/ldd:verify` records the failed checks and blocks closure.
- Scope/design/plan drift: `/ldd:verify` identifies the earliest affected command and stops.
- External drift: `/ldd:verify` stops before closure recommendation and asks for human reconciliation.
- Missing new ledger fields: commands derive state and may backfill `execution_context` during the next mutating command.

### Backwards compatibility

- Existing target repos do not need migration before normal commands run.
- `/ldd:setup` updates templates for new installations only.
- The implementation plan should include a narrow template-update slice and a separate active-ledger backfill slice for this repo's dogfood ticket.

## Data Flow / Control Flow

1. Main parent-ticket path:
   1. `/ldd:design` writes `sdd.md`.
   2. The ledger records `artifacts.sdd.status: draft` and updates `execution_context.next_human_action` to design approval.
   3. `/ldd:plan` writes `plan.md` and `plan.html`.
   4. `/ldd:decompose` previews and then creates child work items.
2. Main child-ticket implementation path:
   1. `/ldd:implement <child-id>` completes implementation evidence and checks.
   2. Child ledger records implementation completion and `closure.status: verification_required`.
   3. `/ldd:next` reports `/ldd:verify <child-id>`.
   4. `/ldd:verify <child-id>` writes `verification.md`.
   5. If verification passes, the child ledger records `artifacts.verification.status: passed` and `closure.status: verified`.
   6. After human approval, archive and external close may proceed.
3. Failure path:
   1. `/ldd:verify` finds missing evidence, failed checks, drift, or scope/design mismatch.
   2. It writes the blocking reason to `verification.md`.
   3. The child remains active and unclosed.
   4. `/ldd:next` continues to report the appropriate corrective gate.

## Interfaces / Contracts

| Contract | Producer | Consumer | Compatibility notes |
| --- | --- | --- | --- |
| `execution_context` ledger section | Mutating `/ldd:*` commands | `/ldd:next`, maintainers, implementation agents | Optional for old ledgers; derived when absent. |
| `artifacts.verification` ledger status | `/ldd:verify` | `/ldd:next`, maintainers, closure/archive flow | Child ledgers only for MVP. |
| `closure` ledger section | `/ldd:implement`, `/ldd:verify`, closure/archive step | `/ldd:next`, external sync flow | Missing section means open/not yet implemented. |
| `verification.md` | `/ldd:verify` | Product reviewers, engineering reviewers, maintainers | Human-readable report, not canonical state by itself. |
| `/ldd:verify` skill | Agent Skills package | Codex, Claude Code, Gemini CLI, future agents | Must be standalone like existing command-shaped skills. |
| Updated `agent-skills.json` and adapter manifests | LDD package source | Installers and host agents | Additive command surface. |
| Updated validation script | Repo maintainers | CI/local validation | Must require `ldd-verify` package files and ban external skill dependencies. |

Minimum evidence for `/ldd:verify` to recommend closure:

- Child work item ID and parent Product Requirement link.
- Approved parent PRD, SDD, and plan.
- Child acceptance criteria and covered user stories.
- Implementation evidence such as commit, diff, PR, or local changed-file summary.
- Check evidence such as automated test output, validation command output, or explicit manual verification notes.
- Drift evidence showing no unresolved external ticket body change when an external tracker is configured.

## Migration / Compatibility

- Migration required: none before use. New fields are optional and can be backfilled by the next mutating LDD command.
- Rollout/backout:
  - Roll out as additive package files and template updates.
  - Backout removes `/ldd:verify` from manifests and returns `/ldd:implement` to its current post-implementation behavior, but existing `verification.md` files may remain as inert artifacts.
- Default behavior:
  - For ledgers without child verification fields, `/ldd:next` derives the next action from implementation status and artifact presence.
  - For child work with implementation evidence but no verification, closure is treated as not verified.
- Compatibility tests:
  - Existing package validation still passes.
  - Validation requires the new command files and manifest entries.
  - Hostile test fixtures cover missing evidence, failed checks, drift, and attempted closure before verification.

## Observability

- Logs: no runtime logging is added; command output states the next gate and reasons.
- Metrics: no automated metrics in MVP. The success metric is reviewability from `ledger.yml`, `execution_context`, and `verification.md`.
- Alerts: none.
- Debugging affordances:
  - `execution_context.next_reason` explains why `/ldd:next` selected the gate.
  - `verification.md` records pass/fail findings and blocking evidence.
  - Ledger events record important transitions such as `verification_failed`, `verification_passed`, and `child_archived`.

## Security / Privacy

- Data touched:
  - Repo-local ticket metadata, artifact paths, implementation evidence summaries, and verification reports.
  - External tracker IDs, URLs, timestamps, and body hashes when configured.
- Permissions/authz:
  - No new permissions are required for local mode.
  - External close/update still requires human confirmation and the host agent's existing tracker credentials.
- Secrets:
  - No secrets are stored in the ledger, `execution_context`, or `verification.md`.
- Abuse cases:
  - A generated verification report could overstate evidence. The command must list concrete evidence paths/commands and block when evidence is missing.
  - An external ticket could be closed despite local failure. The command must not mutate external trackers unless the ledger says verification passed or the human explicitly records an override.

## ADRs

- Existing: none.
- New: none.

The design is additive inside the existing ledger-first command package. It does not change the source-of-truth rule, package ownership boundary, or external tracker model, so it stays below the ADR threshold for this MVP.

## Open Design Questions

| Question | Impact | Owner | Next action |
| --- | --- | --- | --- |
| None. | Planning can proceed. | Engineering | Use this SDD to create an implementation plan. |

## Review Checklist

- [x] Every material PRD goal has a corresponding design decision or explicit non-design note.
- [x] The design is grounded in current code and relevant ADRs.
- [x] No product scope has been added beyond the PRD.
- [x] New architectural decisions have ADRs or are clearly below the ADR threshold.
- [x] Interfaces, migration, observability, and security/privacy have been considered.
- [x] Open questions are either resolved or explicitly block plan approval.
