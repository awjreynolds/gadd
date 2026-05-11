---
description: Diagnose the Ledger-Driven Development workflow state for one GitHub issue
allowed-tools: Read, Glob, Grep, Bash
argument-hint: <issue-number>
---

# /ldd:next

Use the `ldd-core` skill before executing this command.

Read-only diagnostic command.

Input:

```text
/ldd:next <issue-number>
```

## Reads

- GitHub issue state
- linked PRs
- PR branch names
- PR titles and bodies
- PR review / merge state
- expected local branches
- expected local artifacts

It never mutates GitHub.

## Procedure

1. Validate that `$ARGUMENTS` is a single issue number.
2. Read `.ldd/config.yml` if present; otherwise use the GitHub origin remote.
3. Run `gh issue view <issue> --json number,title,state,body,url,closed,closedAt`.
4. Run `gh pr list --state all --search "<issue>" --json number,title,state,isDraft,headRefName,baseRefName,body,url,reviewDecision,mergeStateStatus,mergedAt,closedAt`.
5. Classify PRs by expected branch first, then title/body issue reference:
   - `ldd/prd/<issue>`
   - `ldd/sdd-plan/<issue>`
   - `ldd/impl/<issue>`
6. Check local branches with `git branch --list`.
7. Check local artifacts under `docs/tickets/<issue>/`.
8. Report the current workflow state, next explicit command, and inconsistencies.

## Decision Tree

If issue is closed:
  done

Else if Implementation PR exists:
  inspect Implementation PR state

Else if SDD/Plan PR is merged:
  next: /ldd:implement

Else if SDD/Plan PR exists:
  inspect SDD/Plan PR state

Else if PRD PR is merged:
  next: /ldd:design

Else if PRD PR exists:
  inspect PRD PR state

Else if ldd/prd/<issue> branch exists:
  inspect prd.md completeness and recommend /ldd:scope, /ldd:elaborate, or /ldd:refine

Else:
  next: /ldd:scope

## Stop Conditions

- issue number is missing or invalid
- issue is not found
- GitHub state cannot be read
- more than one PR matches a workflow phase
- a PR references the issue but uses the wrong branch for its phase
- local artifacts imply a later state than GitHub
