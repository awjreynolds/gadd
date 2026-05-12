---
name: ldd-setup
description: Run /ldd:setup to bootstrap a target repository for Ledger-Driven Development. Use when the user says /ldd:setup, asks to set up LDD in a repo, or needs .ldd/config.yml, docs/tickets, local ledger support, and LDD templates created.
---

# /ldd:setup

Bootstrap the current target repository for the LDD MVP workflow.

## Preflight

- Confirm this is a target project, not the LDD skill source repo. If `skills/ldd-setup/SKILL.md` or another LDD skill source exists in the repo, stop and ask whether the user intends to dogfood LDD here.
- Detect whether an external tracker is configured or requested. GitHub, Linear, Jira, and local-only are valid MVP modes.
- If no external tracker is configured, default to local-only mode.

## Create

- `docs/tickets/`
- `docs/tickets/_drafts/`
- `docs/tickets/_archive/`
- `.ldd/config.yml`
- `.ldd/templates/ledger.yml`
- `.ldd/templates/prd.md`
- `.ldd/templates/sdd.md`
- `.ldd/templates/plan.md`
- `.ldd/templates/plan.html`
- `.ldd/templates/pr-body-prd.md`
- `.ldd/templates/pr-body-sdd-plan.md`
- `.ldd/templates/pr-body-implementation.md`

Use bundled templates from `assets/templates/`.

Copy templates exactly unless the user explicitly asks to customize them. The templates include artifact quality guidance and are part of the LDD workflow contract, not just blank markdown scaffolds.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- Every Product Requirement starts in `docs/tickets/_drafts/YYYY-MM-DD-short-slug/` with a `ledger.yml`.
- Promotion moves the draft directory to a stable ticket ID directory using either a local ID such as `LDD-0001` or an external tracker ID.
- Do not create `docs/adr/` during setup. The ADR directory is created or confirmed only when the first ADR is needed.
- Do not push, create external tickets, open PRs, comment, request reviewers, or otherwise mutate an external tracker.
- Show a summary and diff. Commit locally only after explicit human approval.

## Stop Conditions

- `.ldd/config.yml` exists with conflicting settings
