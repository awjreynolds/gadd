---
name: ldd-setup
description: Run /ldd:setup to bootstrap a target repository for Ledger-Driven Development. Use when the user says /ldd:setup, asks to set up LDD in a repo, or needs .ldd/config.yml, docs/tickets, and LDD templates created.
---

# /ldd:setup

Bootstrap the current target repository for the LDD MVP workflow.

## Preflight

- Confirm this is a target project, not the LDD skill source repo. If `skills/ldd-setup/SKILL.md` or another LDD skill source exists in the repo, stop and ask whether the user intends to dogfood LDD here.
- Verify the repo has a GitHub remote.
- Infer the GitHub repository and default branch with `gh repo view --json nameWithOwner,defaultBranchRef`.
- Verify `gh` is installed and authenticated.

## Create

- `docs/tickets/`
- `.ldd/config.yml`
- `.ldd/templates/prd.md`
- `.ldd/templates/sdd.md`
- `.ldd/templates/plan.md`
- `.ldd/templates/plan.html`
- `.ldd/templates/pr-body-prd.md`
- `.ldd/templates/pr-body-sdd-plan.md`
- `.ldd/templates/pr-body-implementation.md`

Use bundled templates from `assets/templates/`.

## Rules

- GitHub is the ledger. Do not create LDD labels, GitHub Actions, progress logs, or audit event files.
- GitHub mutations require human confirmation.
- Do not create `docs/adr/` during setup. The ADR directory is created or confirmed only when the first ADR is needed.
- Do not push, open PRs, comment, request reviewers, or otherwise mutate GitHub.
- Show a summary and diff. Commit locally only after explicit human approval.

## Stop Conditions

- no GitHub remote
- multiple plausible GitHub remotes and no clear origin
- `gh` unavailable or unauthenticated
- default branch cannot be inferred
- `.ldd/config.yml` exists with conflicting settings
