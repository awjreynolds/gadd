# Level 2 Ticket Quality Hardening Design

**Date:** 2026-05-17
**Status:** proposed design
**Context:** hardening GADD skills against real GitHub collaboration flows where engineers or agents may pick up tickets outside the GADD command loop.

## Summary

GADD needs a Level 2 suite that treats ticket quality as a hard gate, not a soft observation. The suite should run against live GitHub sandbox repositories, create normal and adversarial workflow artifacts, inspect the generated tickets and repo-local artifacts, and fail when the result would leave a human engineer or external agent without enough context to work safely.

The goal is not to make GitHub canonical. The repo-local GADD artifacts remain canonical. GitHub issues and PRs are collaboration surfaces that must be concise, human-readable, and durable enough to hand work to an engineer or agent that starts from the ticket rather than from a GADD conversation.

The suite should support a full improvement loop: run the suite, inspect quality findings, fix GADD skills/templates, push the skills, reinstall them into sandbox repositories, rerun the suite, and repeat until both mechanics and ticket quality pass.

## Goals

- Validate both normal and adversarial GitHub-backed GADD flows.
- Fail tickets that are vague, stale, half done, overlong, missing labels, or missing handoff context.
- Prove that a ticket plus referenced repo artifacts is enough for a capable engineer or agent to continue safely.
- Exercise GitNexus-backed code-impact routing for code-changing bug/task flows.
- Keep generated GitHub tickets concise while requiring repo artifacts to hold the deeper boundary, acceptance criteria, and verification detail.
- Review existing sandbox tickets as an audit input, not only newly created tickets.
- Preserve safe sandbox behavior: run IDs, labels, manifests, no token leakage, and cleanup only for run-marked artifacts.

## Non-Goals

- Do not make GitHub issues the source of truth for GADD workflow state.
- Do not require live GitHub tests in default local validation.
- Do not mutate production or unmarked repositories.
- Do not rely on hidden conversation context as a valid handoff mechanism.
- Do not make tickets long enough to duplicate full PRDs, SDDs, or plans.
- Do not make Level 2 depend on a single autonomous agent CLI before the deterministic harness is reliable.

## Current Observations

The checked-in `gadd` Level 2 harness currently validates a single read-only `/gadd:next` smoke case through `fixture-next`.

Existing sandbox repositories already provide useful evidence:

- Product repo: `awjreynolds/gadd-cad-live-test-product`
- Render repo: `awjreynolds/gadd-cad-live-test-render`
- PRD, product SDD, render SDD, adversarial bug issue, and product PR artifacts exist.
- The tickets are understandable, but they expose hardening gaps: missing labels, closed PRD checklist items left unchecked, no explicit managed trace block/hash, weak lifecycle assertions, and an adversarial bug ticket that claims GitNexus is unavailable even though the repo is now indexed.

These observations should seed the quality rubric and provide regression examples for `--audit-existing`.

## Architecture

Add a live GitHub Level 2 harness alongside the existing `fixture-next` runner:

```text
scripts/
  validate-gadd-level2-github.py

tests/level2/
  README.md
  scenarios/
    normal-product-flow.yml
    bug-gitnexus-flow.yml
    drift-reconciliation.yml
    pr-evidence-closure.yml
    handoff-resilience.yml
  harness/
    __init__.py
    github_client.py
    run_level2.py
    cleanup_level2.py
    ticket_quality.py
    artifact_quality.py
    gitnexus_evidence.py
    skill_refresh.py
  .runs/
    <run-id>/manifest.json
```

The harness should have two execution modes:

- `run`: create fresh run-marked GitHub issues, PRs, labels, branches, repo artifacts, and assertions.
- `audit-existing`: inspect known sandbox tickets and repo artifacts without mutating GitHub.

The suite should write a manifest for every run. The manifest records created issue numbers, PR numbers, labels, branch names, artifact paths, quality findings, cleanup status, and links to all live GitHub objects.

## Scenario Families

### 1. Normal Product Flow

Validate the ordinary PRD-to-implementation path:

- create a concise PRD issue,
- create one SDD issue per affected repository,
- create implementation child tickets when decomposition is expected,
- attach child issues through GitHub native sub-issues where available,
- record repo-local PRD, SDD, plan, child ledger, and verification artifact paths,
- verify labels, cross-repo links, review focus, and next action.

The PRD issue must stay product-level. SDD and child issues must explain repo-local implementation boundaries without duplicating the full design.

### 2. Bug Triage With GitNexus

Validate a code-impacting external GitHub issue:

- seed or create a bug report with a concrete reproduction,
- run GitNexus query/context/impact for the affected symbol,
- record direct callers, affected process/risk summary, and route decision,
- create or update the GADD triage artifact and managed GitHub comment,
- fail if the ticket claims GitNexus is missing when GitNexus evidence is available,
- verify the next command is either implementation-ready with evidence or blocked with a precise human decision.

This scenario proves that code-changing work is not routed from intuition alone.

### 3. Drift And Reconciliation

Validate external mutation handling:

- create a projected issue,
- record body/comment/label sync metadata,
- mutate the issue body, add a human comment, and alter managed labels,
- attempt a managed update with stale metadata,
- verify GADD refuses to overwrite and emits a concise reconciliation action.

The failure mode must be explicit and actionable. A generic "sync failed" message is not enough.

### 4. PR Evidence And Closure

Validate PR and closure semantics:

- create a test branch and PR evidence artifact,
- inspect PR state, URL, merge state, merge commit, and timestamps,
- record PR evidence without automatically verifying or closing the work item,
- require explicit verification evidence before closure,
- fail closed tickets with missing verification artifacts or unchecked completion checklists.

GitHub PR state is evidence. It is not workflow closure by itself.

### 5. Agent Handoff Resilience

Validate that someone can work from the ticket and repo artifacts without GADD conversation context:

- ticket identifies the work type and canonical artifact path,
- linked artifact exists in the repo,
- artifact contains boundary, acceptance criteria, and verification expectations,
- next action is unambiguous for a non-GADD agent,
- implementation tickets include enough detail for TDD,
- product/design tickets include enough context for brainstorming/refinement,
- multi-repo tickets state ownership and non-goals clearly,
- parent/child context is reachable without manually searching issue history.

This scenario treats GADD as a collaboration protocol. A ticket passes only if an engineer or capable agent can pick it up safely from GitHub plus the repository.

## Ticket Quality Rubric

The quality gate grades the ticket and referenced repo artifacts together. A concise ticket can pass when it clearly routes the worker to strong local artifacts. A long ticket can fail when it hides the next action or lacks a boundary.

Hard failures:

- title is vague or lacks role context such as PRD, SDD, Bug, Child, or Verification,
- missing problem statement or human-readable context,
- missing boundary or non-goals where scope could expand,
- missing repo ownership for multi-repo work,
- missing next action or reviewer focus,
- missing verification/evidence on closed work,
- unchecked completion checklist items on closed tickets,
- missing managed trace marker, run ID, or artifact reference,
- missing expected labels,
- stale or contradictory statements,
- stale GitNexus availability or impact claims,
- ticket requires hidden conversation context,
- child ticket cannot be understood without manually reading unrelated comments,
- token-like or credential-like material appears in body, comments, manifests, or artifacts,
- issue body exceeds the configured word or section budget without justification.

Recommended limits:

- PRD projection: concise summary, product boundary, non-goals, repo ownership, child links, next review action.
- SDD projection: boundary source, repo-local design summary, files/symbols, verification expectation, reviewer focus.
- Bug projection: observed behavior, expected behavior, reproduction, GitNexus evidence summary, route decision, next action.
- Child work ticket: slice outcome, acceptance criteria, blocked-by links, target artifacts, verification command.

## Artifact Quality Rubric

Repo-local artifacts must carry the detail tickets intentionally omit:

- PRD contains user/problem context, scope, non-goals, acceptance criteria, and affected repositories.
- SDD contains design boundary, affected modules/symbols, tradeoffs, and verification strategy.
- Plan contains implementable slices and dependencies.
- Triage contains source, reproduction, route decision, GitNexus evidence or approved fallback.
- Verification contains commands, outputs, evidence links, and residual risk.
- Ledger state is consistent with ticket labels and next action.

Artifacts fail when links are broken, paths are missing, state contradicts GitHub labels, or acceptance criteria are too thin for a TDD workflow.

## GitNexus Requirements

For code-impacting routes, Level 2 should require GitNexus evidence unless the scenario explicitly tests a human-approved fallback.

Evidence should include:

- affected symbol or file,
- direct callers or consumers,
- affected process when available,
- risk level or blast radius summary,
- freshness status,
- recorded fallback approval only when GitNexus is unavailable.

The suite should use the GitNexus MCP tools when testing indexed local sandbox repositories. If an index is stale, the suite should report that as a blocked route rather than silently accepting stale evidence.

## Skill Push, Reinstall, Rerun Loop

The hardening workflow should be explicit:

1. Run `audit-existing` against current sandbox tickets.
2. Run the live suite against fresh run-marked artifacts.
3. Inspect failures and map them to GADD skills/templates.
4. Fix the skills/templates in `gadd`.
5. Run local validation.
6. Push the updated skill package.
7. Reinstall the skills into product and render sandbox repos.
8. Rerun Level 2.
9. Repeat until both live creation and audit checks pass.

`skill_refresh.py` should not hide mutations. It should print the exact push/reinstall commands and require explicit opt-in flags before executing network or repo mutation steps.

## Safety And Cleanup

- Only configured sandbox repositories may be mutated.
- Every live artifact must include `gadd-l2` and a run-specific marker.
- Cleanup may close issues/PRs and delete branches only when they carry the run marker.
- Failed runs remain open by default for inspection.
- Manifests and logs must redact token-like values.
- Scenario files must never contain tokens.
- Broad destructive operations are out of scope.
- The suite fails closed on missing auth, missing repo config, missing GitNexus evidence, broken artifact references, or ambiguous cleanup targets.

## Success Criteria

The suite is successful when:

- normal product flow tickets are concise, linked, labeled, and understandable,
- bug triage tickets include current GitNexus evidence and safe routing,
- drift scenarios stop unsafe overwrites,
- PR/closure scenarios separate review evidence from verification and closure,
- handoff resilience checks prove tickets plus artifacts are enough for external agents or engineers,
- existing sandbox tickets can be audited with actionable findings,
- repeated fix-push-reinstall-rerun cycles converge on passing ticket quality.

## Open Implementation Notes

- Use the official GitHub REST sub-issues endpoint for native hierarchy checks and keep the API version explicit.
- Prefer standard-library Python plus `gh` where existing authentication is already configured.
- Keep the current `fixture-next` Level 2 runner for fast offline smoke coverage.
- Do not wire live Level 2 into `scripts/validate-gadd-mvp.sh`; keep it explicit and opt-in.
