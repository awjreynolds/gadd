# Scope / Elaborate / Refine Research Update

**Date:** 2026-05-13
**Status:** research memory
**Context:** dogfooding `/ldd:scope`, `/ldd:elaborate`, and `/ldd:refine`

## Sources Reviewed

- `deanpeters/Product-Manager-Skills` at `d68d280f215959fac21bb7599c3fa356a11a488e`
- `Vvlladd/qrspi-orchestrator` at `b6e85e6e84b62deb0ddce1f17a51d267d4bf42ec`
- Local `grill-me` skill at `/Users/awjre/.codex/skills/grill-me/SKILL.md`
- Current local LDD skills:
  - `skills/ldd-scope/SKILL.md`
  - `skills/ldd-elaborate/SKILL.md`
  - `skills/ldd-refine/SKILL.md`

## Executive Finding

The current LDD PM commands have the right ownership boundaries, but they are too thin as operating procedures. They say what each command owns and forbids, but they do not yet teach the agent how to run the conversation, how to preserve user control, how to mark assumptions, or how to turn ambiguity into a reviewable Product Requirement without drifting into design.

The main update should not be a new generic PM dependency. LDD's Standalone Skill Contract still holds. Instead, embed a small LDD-native facilitation protocol into each PM command and strengthen the PRD handoff contract.

## What Product Manager Skills Contributes

`Product-Manager-Skills` is useful less for any single PRD template and more for its skill-design philosophy:

- Skills are both execution instructions and coaching artifacts. The user should understand why the artifact is getting better, not just receive a filled template.
- Interactive skills share a canonical facilitation protocol: set expectations, offer entry mode, ask one question per turn, show progress, provide quick-select options, handle interruptions, and provide recommendations only at decision points.
- Skill frontmatter is treated as trigger metadata, not marketing copy. Short descriptions answer what the skill does and when to load it; richer intent belongs separately.
- Every substantive skill carries explicit anti-patterns. In the LDD context, anti-patterns should name scope expansion, solution smuggling, premature technical design, unowned open questions, and acceptance criteria that prescribe implementation mechanics.
- PRD-quality guidance separates problem, target users, goals, success criteria, user stories, out of scope, dependencies, risks, and open questions. LDD's three PM commands can map cleanly onto those sections without collapsing into one monolithic PRD workflow.

Implication for LDD:

- Add a shared but embedded "PM facilitation protocol" to `/ldd:scope`, `/ldd:elaborate`, and `/ldd:refine`.
- Keep the protocol self-contained in each command-shaped skill. Do not introduce a required `workshop-facilitation` dependency.
- Add progressive modes:
  - `Guided`: ask one question at a time.
  - `Context dump`: user pastes known context; agent skips resolved questions.
  - `Best guess`: agent fills from available context and labels assumptions.
- Use progress labels such as `Scope Q1/3`, `Elaboration Q2/6`, and `Refinement Q3/5`.
- Offer quick-select options for routine product questions, but only offer recommendations when the agent is choosing a path or returning the user to an earlier LDD command.

## What Grill-Me Contributes

The local `grill-me` skill is intentionally tiny:

- Interview relentlessly until shared understanding exists.
- Walk down each branch of the design tree.
- Resolve dependencies between decisions one at a time.
- Provide the recommended answer for each question.
- Ask one question at a time.
- If a question can be answered by exploring the codebase, explore the codebase instead.

For LDD PM commands, the "explore the codebase" clause must be constrained because `/ldd:scope`, `/ldd:elaborate`, and `/ldd:refine` are Product Manager commands. They must not read the codebase as design input. But the rest is highly relevant.

Implication for LDD:

- Add a "grill mode" behavior to PM commands: each blocking ambiguity is asked as a single sharp question with a recommended answer.
- Scope/elaboration/refinement should explicitly resolve decision dependencies rather than asking broad batches of questions.
- The recommendation should be product-facing and boundary-preserving. If the answer would require code facts, capture it as a dependency, constraint, or open question for `/ldd:design`.

## What QRSPI Contributes

QRSPI is a 6-phase human-gated pipeline:

1. Questions
2. Research
3. Structure/Design
4. Plan
5. Implement
6. Pull Request

Its strongest patterns for LDD are:

- Human gates are explicit and mandatory between phases.
- Each phase writes a named artifact before the next phase starts.
- Later phases read approved prior artifacts instead of re-inventing context.
- Status/resume commands inspect artifacts and structured state.
- Agents make explicit next-action statements before stopping.
- Research is separate from design, and implementation is separate from planning.
- The pipeline uses memory-bridging artifacts (`progress.md`, `tasks.json`, `reports/`) for continuity.

QRSPI also has a mismatch with LDD:

- QRSPI uses `progress.md` as an activity log. LDD explicitly rejects duplicate progress logs because the repo-local `ledger.yml` is canonical and ledger events are compact workflow transitions, not session traces.
- QRSPI's Questions phase allows read-only codebase scanning. LDD's PM commands must not use codebase exploration as product/design input.
- QRSPI's implementation tasks are 2-5 minute units. LDD's planned Vertical Slices should be independently reviewable slices, not necessarily microtasks.

Implication for LDD:

- Keep LDD's artifact boundary model, but strengthen explicit gates:
  - `/ldd:scope`: "Scope ready. Continue to elaborate, revise scope, or stop?"
  - `/ldd:elaborate`: "Elaboration ready. Continue to refine, return to scope, or stop?"
  - `/ldd:refine`: "PRD ready for engineering design review?"
- Require every PM command to end with:
  - artifact path updated,
  - ledger status/event expected,
  - unresolved questions,
  - recommended next LDD command,
  - exact human decision needed.
- Do not add `progress.md`; record only meaningful state transitions in `ledger.yml`.
- Use QRSPI's resume insight in `/ldd:next`, not in duplicate files: inspect ledgers and artifacts, then state next action and reason.

## Concrete Updates To Capture

### `/ldd:scope`

Current ownership is correct: goals, non-goals, initial dependencies/constraints.

Needed additions:

- Opening protocol: state that this command only defines product boundary and will not fill problem detail, stories, metrics, or acceptance criteria.
- Intake modes: Guided, Context dump, Best guess.
- Core questions:
  - What product change or outcome is being considered?
  - What goals are in scope?
  - What tempting work is explicitly out of scope?
  - What known constraints or dependencies affect scope?
- Grill behavior: if goals/non-goals conflict, ask one decisive question and recommend the narrower boundary.
- Exit gate: scope complete enough for `/ldd:elaborate`, or blocked with named ambiguity.

### `/ldd:elaborate`

Current ownership is correct: problem, users/personas, stories, draft acceptance criteria, draft metrics, open questions.

Needed additions:

- Opening protocol: confirm it will preserve existing goals/non-goals and will stop if product detail changes scope.
- Core questions:
  - Who experiences the problem?
  - What are they trying to do?
  - What blocks them and why does it matter?
  - What user stories express the required outcomes?
  - What product-facing draft acceptance criteria prove the stories?
  - What metrics would indicate success?
- Use PM Skills' problem framing quality bar: avoid solution-smuggling and generic "better UX" language.
- Treat draft acceptance criteria as product outcomes, not file paths, state machines, schemas, algorithms, or command internals.
- Exit gate: elaboration complete enough for `/ldd:refine`, or return to `/ldd:scope` if goals/non-goals need change.

### `/ldd:refine`

Current ownership is correct: testable acceptance criteria, measurable metrics, owned open questions, dependencies, removal of vague/solution-smuggling language.

Needed additions:

- Opening protocol: refinement sharpens handoff quality and does not add scope or design.
- Systematic checks:
  - Every goal has at least one acceptance criterion or explicit reason it does not.
  - Every user story is covered by acceptance criteria.
  - Every acceptance criterion is observable by a reviewer without prescribing implementation mechanics.
  - Success metrics include baseline/target or an explicit measurement owner.
  - Dependencies name owner/status.
  - Open questions are resolved, owned, or explicitly non-blocking.
  - Non-goals still block obvious scope creep.
- Grill behavior: ask one blocking handoff question at a time and include recommended resolution.
- External projection: preserve the rich Product Requirement ticket model from current `/ldd:refine`.
- Exit gate: ask the PRD reviewer question exactly: "Is this ready for engineering design?"

## Recommended Skill Shape

Each PM command should include these sections:

```markdown
## Facilitation Protocol

- State expected output and boundary.
- Offer Guided / Context dump / Best guess.
- Ask one question at a time when blocked.
- Use progress labels.
- Provide numbered quick-select options when useful.
- Give recommendations only at decision points.
- If interrupted, answer directly, restate status, then resume.

## Product Quality Bar

- Required sections this command may edit.
- Sections this command must preserve or leave blank.
- Anti-patterns this command must reject.

## Exit Gate

- Artifact updated.
- Ledger transition/event.
- Blocking questions.
- Recommended next command.
- Human decision required.
```

Because LDD skills must be standalone, duplicate this minimal protocol into `ldd-scope`, `ldd-elaborate`, and `ldd-refine` rather than requiring a shared installed skill.

## Open Product Decisions

- Should `Best guess` mode be allowed to write artifacts immediately, or should it always preview assumptions first?
  - Recommended: allow artifact updates, but label assumptions inline and list them under Open Questions unless the user asked for preview-only behavior.
- Should `/ldd:scope` create a draft ticket directory when no active draft exists, or remain blocked on missing ledger?
  - Decision: create a new draft when no active draft exists. Existing promoted tickets, including incomplete tickets, do not block new Product Requirement scoping. Keep one active local draft; if a draft already exists, continue it or explicitly resolve it before starting another.
- Should `/ldd:refine` promote after local PRD refinement?
  - Decision: yes, once the human approves the refined PRD. Approval is the gate that commits the final PRD and turns the draft into a real Product Requirement ticket.

## Update Priority

1. Patch `skills/ldd-scope/SKILL.md`, `skills/ldd-elaborate/SKILL.md`, and `skills/ldd-refine/SKILL.md` with the embedded facilitation protocol and exit gates.
2. Mirror behavior in Claude/Gemini adapters only if adapter text stops being a thin pointer.
3. Add validation expectations to the PRD template checklist if needed, especially around solution-smuggling and owned open questions.
4. Re-run `./scripts/validate-ldd-mvp.sh`.
