---
ticket: {ticket}
title: "{title}"
created: {date}
updated: {date}
---

# PRD: {title}

<!--
PM-hat artifact. Describe the product need and acceptance boundary.
Do not use the codebase as design input. Do not include implementation choices,
architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets.
Capture technical uncertainty only as a dependency, constraint, or open question.
-->

## Problem

<!--
Explain the user-visible problem in plain domain language.
Good: names the affected users, current pain, why now, and consequence of doing nothing.
Avoid: proposing a technical solution, restating the ticket title, or mixing several unrelated problems.
-->

TODO: What problem are we solving, for whom, and why does it matter now?

## Goals

<!--
List measurable product outcomes this PRD commits to.
Good: outcome-oriented, testable by behavior or observable result.
Avoid: implementation tasks, internal architecture, or vague improvements like "make it better".
-->

- TODO: Goal 1
- TODO: Goal 2

## Non-goals

<!--
Name tempting work that is intentionally out of scope.
Good: prevents scope creep and protects downstream design from hidden assumptions.
Avoid: saying "none" unless the feature is truly atomic.
-->

- TODO: Non-goal 1

## Users / Personas

<!--
Identify the actors whose workflow changes.
Good: uses real product/domain roles and describes their need or constraint.
Avoid: generic "user" when a more precise actor exists.
-->

- TODO: Actor - need or constraint

## User Stories

<!--
Use "As a <persona>, I want <capability>, so that <benefit>".
Good: covers the main path, edge cases users can observe, and permission/role differences.
Avoid: Gherkin/Cucumber syntax here, stories about components, services, data models, or implementation steps.
-->

1. TODO: As a ..., I want ..., so that ...

## Acceptance Criteria

<!--
Define the product behavior that must be true before engineering can call the work done.
Good: concrete, externally observable, unambiguous, includes important negative cases.
Avoid: "works correctly", file-level checks, framework-specific behavior, or test instructions.
Use checklist bullets for simple criteria. Use Gherkin-style Given/When/Then scenarios when state, roles, or edge cases need precision.
-->

- [ ] TODO: Observable behavior
- [ ] TODO: Important constraint or negative case

```gherkin
Scenario: TODO observable behavior
  Given TODO precondition
  When TODO user action or event
  Then TODO user-visible outcome
```

## Success Metrics

<!--
State how success will be judged after release.
Good: metric, target/change direction, and measurement source when known.
Avoid: vanity metrics or internal engineering measures unless they directly express user value.
-->

- TODO: Metric - expected movement or threshold

## Dependencies

<!--
List inputs, decisions, teams, releases, policies, or external systems this PRD depends on.
Good: distinguishes confirmed dependencies from assumptions.
Avoid: turning dependencies into implementation design.
-->

- TODO: Dependency or constraint

## Open Questions

<!--
Ask only questions that block product scope, acceptance, or rollout confidence.
Good: has an owner or next action where possible.
Avoid: technical design questions that belong in the SDD unless they change product scope.
-->

- TODO: Question - owner/next action

## PRD Handoff Checklist

<!-- Complete before opening the PRD PR. -->

- [ ] Problem is expressed from the user's perspective.
- [ ] Goals and non-goals make the scope boundary clear.
- [ ] User stories cover the main workflow and meaningful user-visible edge cases.
- [ ] Acceptance criteria are observable without reading code.
- [ ] Metrics define how product success will be judged.
- [ ] Dependencies and open questions are explicit.
- [ ] No implementation decisions, architecture, file paths, APIs, schemas, libraries, test strategy, or code snippets are present.
