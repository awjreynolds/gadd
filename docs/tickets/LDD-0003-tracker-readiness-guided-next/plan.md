---
ticket: LDD-0003
prd: docs/tickets/LDD-0003-tracker-readiness-guided-next/prd.md
sdd: docs/tickets/LDD-0003-tracker-readiness-guided-next/sdd.md
created: 2026-05-13
updated: 2026-05-13
status: approved
---

# Implementation Plan: Make LDD ready for external trackers and guided next actions

## Context

`LDD-0003` turns the tracker-readiness discovery into concrete workflow behavior. The approved PRD defines four required-for-use gaps:

- GitHub-first visibility for real project work.
- `/ldd:next` safe continuation guidance.
- Explicit `/ldd:approve <ticket-id>` for PRD and SDD approval.
- PM shared-understanding gates that prevent plausible but misaligned artifacts.

The approved SDD keeps the repo-local ledger canonical, makes GitHub a managed projection rather than the source of truth, and limits `/ldd:approve` to PRD and SDD approvals. Linear and Jira remain documented follow-on collaboration surfaces.

## Implementation Strategy

Implement the work as command-surface and workflow-contract changes. There is no shared runtime module to extend, so each slice updates the standalone skills, adapters, manifests, docs, and validation checks that make LDD installable and dogfoodable.

The plan intentionally avoids a full GitHub API implementation. The SDD calls for GitHub-first visibility contracts using existing managed projection templates and human-confirmed mutation rules. This keeps the first delivery useful and testable without creating a broad sync engine.

## Slices

### Slice 1: `/ldd:approve` command surface

Add `/ldd:approve` as a first-class command-shaped skill for PRD and SDD approval.

Files and modules:

- `skills/ldd-approve/SKILL.md`
- `skills/ldd-approve/agents/openai.yaml`
- `commands/ldd/approve.md`
- `commands/ldd/approve.toml`
- `agent-skills.json`
- `.claude-plugin/plugin.json`
- `gemini-extension.json`
- `scripts/validate-ldd-mvp.sh`
- `README.md`
- `GEMINI.md`

Acceptance coverage:

- `/ldd:approve <ticket-id>` can infer PRD vs SDD approval when exactly one gate is active.
- `/ldd:approve` does not approve plan, decomposition, closure, or external mutations.
- Approval is durable in artifact frontmatter, ledger artifact status, approved artifact boundaries, and events.

### Slice 2: Guided `/ldd:next` and approval-routing gates

Update existing workflow skills so the next human action is explicit and commandable.

Files and modules:

- `skills/ldd-next/SKILL.md`
- `skills/ldd-refine/SKILL.md`
- `skills/ldd-design/SKILL.md`
- `skills/ldd-plan/SKILL.md`
- `skills/ldd-decompose/SKILL.md`
- `skills/ldd-implement/SKILL.md`
- `skills/ldd-verify/SKILL.md`
- `skills/ldd-close/SKILL.md`

Acceptance coverage:

- `/ldd:next` reports both `next_command` and `next_human_action` when available.
- PRD and SDD approval gates name `/ldd:approve <ticket-id>`.
- Durable state changes remain outside `/ldd:next`; it offers the next action without mutating.
- Blocked states report the human decision or drift resolution required.

### Slice 3: GitHub-first tracker projection contracts

Make the external tracker boundary explicit in the command contracts and setup templates.

Files and modules:

- `skills/ldd-setup/assets/templates/config.yml`
- `skills/ldd-setup/assets/templates/issue-body-prd.md`
- `skills/ldd-setup/assets/templates/issue-body-child.md`
- `skills/ldd-setup/assets/templates/pr-body-sdd-plan.md`
- `skills/ldd-setup/assets/templates/pr-body-implementation.md`
- Relevant command skills that create, review, verify, or close work.

Acceptance coverage:

- GitHub is documented as the first external tracker dogfooding path.
- GitHub issues are the projection surface for PRD and child work.
- GitHub PRs are the projection surface for SDD/plan and implementation review.
- External mutation requires human confirmation.
- Local ledger remains canonical and external drift stops mutation.
- Linear and Jira remain follow-on, optional collaboration surfaces.

### Slice 4: Shared-understanding guardrails and validation

Preserve and validate the PM shared-understanding behavior that motivated this ticket.

Files and modules:

- `skills/ldd-scope/SKILL.md`
- `skills/ldd-elaborate/SKILL.md`
- `skills/ldd-refine/SKILL.md`
- `scripts/validate-ldd-mvp.sh`
- `README.md`
- `CONTEXT.md`

Acceptance coverage:

- PM commands require a bounded shared-understanding gate before marking a PRD ready.
- Validation catches accidental removal of those gates.
- Documentation explains the balance between grill-style understanding and LDD scope control.

### Slice 5: End-to-end docs and package verification

Finish the user-facing workflow surface and run installability validation.

Files and modules:

- `README.md`
- `GEMINI.md`
- `CONTEXT.md`
- `scripts/validate-ldd-mvp.sh`
- `docs/tickets/LDD-0003-tracker-readiness-guided-next/verification.md`

Acceptance coverage:

- Command lists include `approve` everywhere users and packages discover LDD commands.
- Validation checks the new command, manifests, docs, tracker-readiness language, and PM gate language.
- Verification evidence is recorded before closure.

## Traceability

| PRD acceptance area | Plan coverage |
| --- | --- |
| Functional gap inventory and required-vs-optional classification | Already satisfied in PRD; preserved in README/CONTEXT docs through slices 3-5 |
| GitHub-first path | Slice 3 |
| Linear/Jira follow-on classification | Slice 3 and Slice 5 |
| External tracker mandatory capabilities | Slice 3 |
| External tracker mutations require confirmation | Slice 3 |
| `/ldd:next` reports and offers next action | Slice 2 |
| `/ldd:next` asks for human decision when blocked | Slice 2 |
| `/ldd:approve <ticket-id>` PRD/SDD approval | Slice 1 and Slice 2 |
| `/ldd:approve` excludes plan/decomposition/closure/external mutations | Slice 1 |
| PM shared-understanding gate | Slice 4 |

## Test Strategy

- Run `bash scripts/validate-ldd-mvp.sh` after each substantial package-surface change.
- Use local grep-based checks in the validation script to verify:
  - The `approve` command exists in skill, adapter, manifest, README, and Gemini surfaces.
  - PM skill guardrails mention bounded shared understanding.
  - GitHub-first visibility and local-ledger-canonical wording is present.
  - `/ldd:next` names `next_human_action` and `/ldd:approve <ticket-id>` for approval gates.
- Manually inspect representative ledgers and skills for phase safety:
  - `/ldd:approve` only mutates PRD/SDD gates.
  - `/ldd:next` remains read-only.
  - GitHub mutation rules require human confirmation and drift checks.

## Review Checklist

- [x] Plan is derived from approved PRD and SDD.
- [x] Slices are independently reviewable and map to acceptance criteria.
- [x] No slice makes an external tracker canonical.
- [x] No slice expands `/ldd:approve` beyond PRD and SDD approval.
- [x] Linear and Jira remain follow-on scope.
- [x] Verification is defined before implementation starts.

