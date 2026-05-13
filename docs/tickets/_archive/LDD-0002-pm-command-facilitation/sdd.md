---
ticket: LDD-0002
title: "Strengthen LDD PM command facilitation"
created: 2026-05-13
updated: 2026-05-13
status: approved
---

# Software Design Document: Strengthen LDD PM command facilitation

## Overview

This design updates the three Product Manager command-shaped skills so each command can run a guided product conversation without relying on external skills. The implementation stays inside the command contracts that already own the behavior: `/ldd:scope`, `/ldd:elaborate`, and `/ldd:refine`.

No new runtime subsystem, shared installed skill, external agent dependency, or global workflow state is introduced. The design keeps repo-local ledgers as canonical state and uses the existing PRD artifact boundaries.

## Existing System

- LDD commands are standalone skill files under `skills/ldd-*/SKILL.md`.
- `commands/ldd/*.md` and `commands/ldd/*.toml` are thin adapters that point to canonical skill files.
- `/ldd:scope` already supports creating a new draft when no active draft exists and prevents unrelated promoted tickets from blocking new scoping.
- `/ldd:elaborate` already protects existing scope and keeps acceptance criteria draft-quality.
- `/ldd:refine` already handles handoff-quality checks, approval prompting, and draft promotion.
- The PRD template already warns against implementation detail and solution-smuggling.

## Design Goals

- Add enough facilitation structure that agents know how to ask, infer, label assumptions, and stop.
- Keep the instructions duplicated in the three PM command skills so each installed command remains standalone.
- Preserve phase ownership:
  - `/ldd:scope`: goals, non-goals, initial dependencies or constraints.
  - `/ldd:elaborate`: problem, users, stories, draft acceptance criteria, draft metrics, open questions.
  - `/ldd:refine`: testable acceptance criteria, measurable metrics, owned open questions, dependencies, and vague-language cleanup.
- Keep all guidance product-facing and avoid design or implementation mechanics.

## Components

### PM Facilitation Protocol

**Files:** `skills/ldd-scope/SKILL.md`, `skills/ldd-elaborate/SKILL.md`, `skills/ldd-refine/SKILL.md`

Each command receives an embedded facilitation protocol with the same shape:

- State the command boundary before filling the PRD.
- Support three interaction modes:
  - `Guided`: ask one question at a time.
  - `Context dump`: infer from supplied context and skip resolved questions.
  - `Best guess`: proceed from available context and label assumptions.
- Ask one decisive question when a product ambiguity blocks progress.
- Use quick-select options only when useful.
- Give recommendations at decision points, especially when returning to an earlier LDD command.
- If interrupted, answer the interruption, restate status, and resume the current PM phase.

### PM Quality Bars

**Files:** `skills/ldd-scope/SKILL.md`, `skills/ldd-elaborate/SKILL.md`, `skills/ldd-refine/SKILL.md`

Each command gets phase-specific anti-patterns:

- `/ldd:scope` rejects premature product detail, acceptance criteria, metrics, user stories, and technical design.
- `/ldd:elaborate` rejects scope expansion, implementation-specific acceptance criteria, and generic problem language.
- `/ldd:refine` rejects unowned open questions, vague acceptance criteria, unmeasurable metrics, and solution-smuggling.

### Exit Gates

**Files:** `skills/ldd-scope/SKILL.md`, `skills/ldd-elaborate/SKILL.md`, `skills/ldd-refine/SKILL.md`

Each command ends with the same handoff shape:

- Artifact updated.
- Ledger transition expected.
- Blocking or non-blocking questions.
- Recommended next LDD command or return path.
- Required human decision.

## Data Flow

1. User invokes an LDD PM command.
2. Command identifies the active draft or promoted ticket according to its existing target rules.
3. Command states its PM boundary and interaction mode.
4. Command fills only owned PRD sections.
5. If ambiguity changes scope or ownership, command returns to the earliest affected PM command.
6. Command records or expects the matching ledger event and routes to the next LDD command.

## Interface Contracts

No CLI flags, manifests, adapter contracts, or external tracker contracts change.

The user-facing command contract changes are textual:

- `/ldd:scope` can start a new draft when no active draft exists and explains duplicate-draft handling.
- `/ldd:elaborate` provides a guided product-detail flow inside existing scope.
- `/ldd:refine` provides a guided handoff-quality flow and explicit PRD approval prompt.

## Error Handling

- If a new draft is requested while one active draft exists, `/ldd:scope` stops and asks the user to resolve the existing draft first.
- If multiple active drafts exist, `/ldd:scope` stops and asks for reconciliation.
- If elaboration would change goals or non-goals, `/ldd:elaborate` stops and routes back to `/ldd:scope`.
- If refinement finds untestable acceptance criteria or unowned open questions, `/ldd:refine` asks one blocking handoff question at a time or routes back to the earliest affected PM step.

## ADR Check

No ADR is required. The design updates existing command contracts with clearer text. It does not introduce a hard-to-reverse architecture decision, new dependency, new storage model, or surprising behavior outside the approved PRD.

## Test Strategy

- Run `git diff --check`.
- Run `./scripts/validate-ldd-mvp.sh` when unrelated working-tree changes do not block it.
- Add targeted validation or grep checks only if they can be added without colliding with concurrent work.
- Manually inspect the three PM command skill files for:
  - embedded facilitation protocol,
  - phase-specific quality bar,
  - exit gate,
  - no external skill dependency,
  - no product/design boundary violation.

## Rollout / Backout

- Rollout is immediate once the skill files are updated and committed.
- Backout is a revert of the skill-file text changes for `ldd-scope`, `ldd-elaborate`, and `ldd-refine`.
- Existing tickets and ledgers remain valid because no schema change is introduced.

## Review Checklist

- [x] Design implements the approved PRD without expanding product scope.
- [x] Product Manager boundaries remain distinct from engineering design and implementation.
- [x] No external skill dependency is introduced.
- [x] No ADR is required.
- [x] Verification approach is defined.
