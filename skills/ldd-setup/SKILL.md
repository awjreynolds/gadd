---
name: ldd-setup
description: Run /ldd:setup to bootstrap a target repository for Ledger-Driven Development. Use when the user says /ldd:setup, asks to set up LDD in a repo, or needs .ldd/config.yml, docs/tickets, local ledger support, and LDD templates created.
---

# /ldd:setup

Bootstrap the current target repository for the LDD MVP workflow.

## Preflight

- Confirm this is a target project, not the LDD skill source repo. If `skills/ldd-setup/SKILL.md` or another LDD skill source exists in the repo, stop and ask whether the user intends to dogfood LDD here.
- Detect whether `.ldd/config.yml` already exists.
  - If it exists, treat this as a setup rerun. Read and summarize the current settings before changing files:
    - ledger mode, draft directory, archive directory, local ID prefix
    - tracker provider, repo/project/default branch
    - artifact root
    - branch and PR naming patterns
    - plan renderer setting
    - ADR directory and update policy
  - Ask the human to confirm whether to keep these settings or change them. Do not silently change existing settings.
  - If the existing config conflicts with the requested setup mode and the human has not explicitly approved the change, stop.
- If `.ldd/config.yml` does not exist, ask whether to use local-only mode or GitHub projection mode.
  - Local-only is the recommended default.
  - GitHub is the first MVP external tracker projection path. If selected, ask for the GitHub repo and default branch before writing config.
  - Linear and Jira are follow-on compatibility targets and should be recorded as future intent, not configured as working providers.
- External tracker setup only configures projection intent. Future external mutations still require explicit human confirmation and drift checks.

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
- `.ldd/templates/verification.md`
- `.ldd/templates/issue-body-prd.md`
- `.ldd/templates/issue-body-child.md`
- `.ldd/templates/pr-body-prd.md`
- `.ldd/templates/pr-body-sdd-plan.md`
- `.ldd/templates/pr-body-implementation.md`

Use bundled templates from `assets/templates/`.

Copy templates exactly unless the user explicitly asks to customize them. The templates include artifact quality guidance and are part of the LDD workflow contract, not just blank markdown scaffolds.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- GitHub-first tracker readiness means GitHub issues for PRD/child work and GitHub PRs for SDD/plan/implementation review, all as managed projections of the repo-local ledger.
- Linear and Jira remain optional follow-on collaboration surfaces until the GitHub projection model is proven.
- Every Product Requirement starts in `docs/tickets/_drafts/YYYY-MM-DD-short-slug/` with a `ledger.yml`.
- Promotion moves the draft directory to a stable ticket ID directory using either a local ID such as `LDD-0001` or an external tracker ID.
- Do not create `docs/adr/` during setup. The ADR directory is created or confirmed only when the first ADR is needed.
- Do not push, create external tickets, open PRs, comment, request reviewers, or otherwise mutate an external tracker.
- Show a summary and diff. Commit locally only after explicit human approval.

## Stop Conditions

- `.ldd/config.yml` exists with conflicting settings
