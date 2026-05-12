## Issue

References {ticket}

## PRD

`docs/tickets/{ticket}/prd.md`

## Goals / Non-goals Summary

{summary}

## PM Boundary

This PR should be reviewed as product scope, not technical design.

- The PRD should define the user problem, goals, non-goals, users, stories, acceptance criteria, metrics, dependencies, and open questions.
- It should not contain implementation decisions, architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets.
- Technical uncertainty should appear only as a dependency, constraint, or open question.

## Handoff Checklist

- [ ] Problem is clear from the user's perspective.
- [ ] Goals and non-goals create a usable scope boundary.
- [ ] User stories cover the main workflow and important user-visible edge cases.
- [ ] Acceptance criteria are concrete and externally observable.
- [ ] Success metrics are defined or the reason they are unknown is stated.
- [ ] Dependencies and open questions are explicit enough for engineering design to start.
- [ ] No technical design or implementation content has leaked into the PRD.

## Reviewer Prompt

Is this PRD ready for engineering design, or does product scope need another pass?
