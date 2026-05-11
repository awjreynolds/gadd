---
description: Bootstrap the repository for the Ledger-Driven Development MVP workflow
allowed-tools: Read, Write, Glob, Grep, Bash
argument-hint: ""
---

# /ldd:setup

Use the `ldd-core` skill before executing this command.

Bootstraps the current repository for the MVP workflow.

## Contract

- verify the repo has a GitHub remote
- infer the GitHub repository and default branch
- verify `gh` is installed and authenticated
- create `docs/tickets/`
- create `.ldd/config.yml`
- create local templates for `prd.md`, `sdd.md`, `plan.md`, `plan.html`, and PR bodies
- create or confirm the ADR directory configured in `.ldd/config.yml` only when the first ADR is needed

It should not create labels or GitHub Actions in the MVP.

## Procedure

1. Run `git remote -v` and identify the GitHub origin remote.
2. Run `gh auth status` and stop if authentication is unavailable.
3. Run `gh repo view --json nameWithOwner,defaultBranchRef` and use the result for `.ldd/config.yml`.
4. Create `docs/tickets/` if missing.
5. Create `.ldd/templates/` if missing.
6. Write `.ldd/config.yml` from `.claude/skills/ldd-core/templates/config.yml`.
7. Copy the artifact and PR body templates into `.ldd/templates/`.
8. Summarize changed files.
9. Create a local commit only after showing the diff summary to the human and receiving approval.

## Stop Conditions

- no GitHub remote
- multiple plausible GitHub remotes and no clear origin
- `gh` is unavailable
- `gh` is unauthenticated
- default branch cannot be inferred
- `.ldd/config.yml` exists with conflicting settings; show the diff and ask how to proceed

## Human Control

Do not push. Do not create labels. Do not create GitHub Actions. Do not mutate GitHub.
