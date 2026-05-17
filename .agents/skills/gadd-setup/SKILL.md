---
name: gadd-setup
description: Run /gadd:setup to bootstrap a target repository for GADD. Use when the user says /gadd:setup, asks to set up GADD in a repo, or needs gadd/config.yml, gadd/work-items, local ledger support, and GADD templates created.
---

# /gadd:setup

Bootstrap the current target repository for the GADD MVP workflow.

This command is a standalone, agent-agnostic GADD command. Follow this file directly; do not require any other installed skill.

## Preflight

- Confirm this is a target project, not the GADD skill source repo. If `skills/gadd-setup/SKILL.md` or another GADD skill source exists in the repo, stop and ask whether the user intends to dogfood GADD here.
- Detect whether `gadd/config.yml` already exists.
  - If it exists, treat this as a setup rerun. Read and summarize the current settings before changing files:
    - workflow mode, draft directory, archive directory, local ID prefix
    - tracker provider, repo/project/default branch
    - artifact root
    - code intelligence provider, recommendation level, related repositories, and freshness policy
    - branch and PR naming patterns
    - plan renderer setting
    - ADR directory and update policy
  - Ask the human to confirm whether to keep these settings or change them. Do not silently change existing settings.
  - If the existing config conflicts with the requested setup mode and the human has not explicitly approved the change, stop.
- If `gadd/config.yml` does not exist, ask whether to use local-only mode or GitHub projection mode.
  - Local-only is the recommended default.
  - GitHub is the first MVP external tracker projection path. If selected, ask for the GitHub repo and default branch before writing config.
  - Linear and Jira are follow-on compatibility targets and should be recorded as future intent, not configured as working providers.
- External tracker setup only configures projection intent. Future external mutations still require explicit human confirmation and drift checks.
- GitNexus is expected for normal GADD operation and required for impact-aware triage routing. Setup must not silently install GitNexus or index repositories, but it must record the required triage policy, detect availability when practical, and print the exact setup or refresh action the human needs before `/gadd:triage` can route code-impacting Work Items.

## Create

- `gadd/work-items/`
- `gadd/work-items/_drafts/`
- `gadd/work-items/_archive/`
- `gadd/config.yml`
- `gadd/templates/work-item-ledger.yml`
- `gadd/templates/triage.md`
- `gadd/templates/research.md`
- `gadd/templates/prd.md`
- `gadd/templates/sdd.md`
- `gadd/templates/plan.md`
- `gadd/templates/plan.html`
- `gadd/templates/verification.md`
- `gadd/templates/issue-body-work-item.md`
- `gadd/templates/issue-body-prd.md`
- `gadd/templates/issue-body-sdd.md`
- `gadd/templates/pr-body-prd.md`
- `gadd/templates/pr-body-sdd-plan.md`
- `gadd/templates/pr-body-implementation.md`

Use bundled templates from `assets/templates/`.

Copy templates exactly unless the user explicitly asks to customize them. The templates include artifact quality guidance and are part of the GADD workflow contract, not just blank markdown scaffolds.

When writing `gadd/config.yml`, include the required triage `code_intelligence` policy from the bundled template. If GitNexus appears unavailable, unindexed, or stale, report that limitation and print the exact setup or refresh action the human needs before `/gadd:triage` can route code-impacting Work Items. Do not silently install GitNexus, run indexing, refresh indexes, clean indexes, or mutate sibling repositories.

## Input Quality Gate

Required input standard before writing setup files:

- confirmed target repository context
- confirmed setup mode on first run: local-only or GitHub projection
- confirmed existing settings on rerun before any change
- safe destination directories for `gadd/` and `gadd/work-items/`
- confirmed code-intelligence config if the user wants to add related repositories during setup

If these inputs are missing or conflict with existing setup state, write nothing and ask the narrowest confirmation question. The earliest GADD command that can repair the gap is `/gadd:setup`.

## Rules

- Repo-local ledger is canonical. External trackers are optional sync/review surfaces.
- External mutations require human confirmation.
- GitHub-first tracker readiness means GitHub issues for PRD, SDD, and child work visibility and GitHub PRs for implementation review, all as managed projections of the repo-local ledger.
- Linear and Jira remain optional follow-on collaboration surfaces until the GitHub projection model is proven.
- Every Work Item starts in `gadd/work-items/_drafts/YYYY-MM-DD-short-slug/` with a `ledger.yml`.
- Promotion moves the draft directory to a stable Work Item ID directory. Local mode uses the configured local prefix. GitHub mode creates or binds the external issue during approval and records the external issue number in the Work Item ledger.
- Do not create `docs/adr/` during setup. The ADR directory is created or confirmed only when the first ADR is needed.
- Treat GitNexus as required evidence for impact-aware triage routing, not canonical GADD state. Setup may write required triage configuration and recommend indexing, but it must not perform GitNexus installation, analysis, refresh, cleanup, or cross-repo mutation without explicit human approval.
- Do not push, create external issues, open PRs, comment, request reviewers, or otherwise mutate an external tracker.
- Show a summary and diff. Commit locally only after explicit human approval.

## Stop Conditions

- `gadd/config.yml` exists with conflicting settings
- a bundled template asset is missing or unreadable
- the configured archive target already exists and would be overwritten without human approval
- the requested setup mode differs from existing config and the human has not explicitly approved the mode change
- a GitNexus install, index, or refresh action is requested without explicit human approval
