---
ticket: 1
prd: docs/tickets/1-add-research-and-phase-gates/prd.md
sdd: docs/tickets/1-add-research-and-phase-gates/sdd.md
created: 2026-05-14
updated: 2026-05-14
status: approved
plan_html: docs/tickets/1-add-research-and-phase-gates/plan.html
adrs: []
---

# Implementation Plan: Add LDD research and phase input gates

## Review Context

This plan translates the approved PRD and SDD into executable slices. It adds `/ldd:research`, makes input-quality gates explicit across all LDD commands, strengthens `/ldd:scope`, and preserves the GitHub issue hierarchy already approved for PRD and SDD projection.

### PRD Summary

- Source: `docs/tickets/1-add-research-and-phase-gates/prd.md`
- Goals covered:
  - Add a first-class research phase before scoping when inputs are weak, sensitive, or need codebase investigation.
  - Let research use full read-only repository and local context visibility.
  - Add input-quality gates across LDD phases.
  - Strengthen `/ldd:scope` so weak inputs route to research or missing-input questions.
  - Keep private and financially sensitive PM intake out of committed and GitHub-visible artifacts.
  - Validate GitHub projection while keeping the repo-local ledger canonical.
- Non-goals to protect:
  - GitHub must not become canonical workflow state.
  - `/ldd:scope` must not mutate GitHub.
  - No Linear/Jira behavior.
  - No raw private financial, customer, revenue, budget, or commercial notes in committed or GitHub-visible artifacts.
  - Research must not prescribe architecture, command algorithms, file placement, schemas, implementation sequencing, or tests.
  - Do not collapse LDD phases into one command.
- Acceptance criteria:
  - Research prompts for standard PM inputs.
  - Research has full read-only code/docs/artifact/private-local context visibility.
  - Research output separates evidence, codebase facts, constraints, assumptions, risks, sensitivity handling, and open questions.
  - Research reports one readiness label.
  - Scope refuses to write goals/non-goals without a clear problem or desired product outcome.
  - Scope routes weak inputs to research or asks for missing context.
  - Every phase states its required input standard before mutation.
  - Phase rejections name the blocking gap and earliest fixing command.
  - Sensitive private inputs are sanitized before committed or GitHub-visible output.
  - GitHub projection remains explicit, human-confirmed, and ledger-canonical.

### SDD Summary

- Source: `docs/tickets/1-add-research-and-phase-gates/sdd.md`
- Design decisions to implement:
  - Add `/ldd:research` as a normal standalone command-shaped skill with Codex, Claude, and Gemini adapter coverage.
  - Add optional `artifacts.research.path/status` ledger fields and a `research.md` template.
  - Store only sanitized research conclusions and redaction notes in committed artifacts.
  - Keep PM commands inside the product boundary while allowing research full read-only code visibility.
  - Add an `Input Quality Gate` section to every command skill.
  - Make scope refuse weak inputs before writing PRD scope.
  - Extend validation to require research command files, manifests, templates, and gate language.
- Interfaces/contracts to preserve:
  - `skills/ldd-*/SKILL.md` files are canonical.
  - Adapter files are command routers.
  - Repo-local `ledger.yml` is canonical workflow state.
  - External mutations require explicit human confirmation.
  - SDD issue `#2` remains the GitHub child of PRD issue `#1`; future decomposition child issues reference SDD issue `#2`.
- Migration/compatibility requirements:
  - Existing ledgers without `artifacts.research` remain valid.
  - Research is optional when `/ldd:scope` receives equivalent adequate inputs.
  - Setup installs the new research template and ledger field for future tickets.

### ADR Summary

- ADRs: []
- Design rules that affect implementation:
  - No ADR is needed for this change because it extends the existing standalone skill and repo-local ledger model.
  - Planning must not introduce a shared runtime, schema migration engine, or new external source of truth.

## Slices

Use these slices as the planned `/ldd:decompose` input. Each slice leaves the package in a reviewable state and includes its own verification.

| Slice | Outcome | Files/modules | Tests/checks | Dependencies |
| --- | --- | --- | --- | --- |
| 1. Research command surface | `/ldd:research` is discoverable and installable across Codex, Claude, and Gemini. | `skills/ldd-research/SKILL.md`, `skills/ldd-research/agents/openai.yaml`, `commands/ldd/research.md`, `commands/ldd/research.toml`, `agent-skills.json`, `.claude-plugin/plugin.json`, `gemini-extension.json`, `README.md`, `GEMINI.md` | `./scripts/validate-ldd-mvp.sh`; manifest JSON validation; grep checks for `/ldd:research` command coverage. | None. |
| 2. Research artifact, ledger, and setup templates | New setup installs `research.md`; ledgers can record optional research state without breaking old tickets. | `skills/ldd-setup/assets/templates/research.md`, `.ldd/templates/research.md`, `skills/ldd-setup/assets/templates/ledger.yml`, `.ldd/templates/ledger.yml`, `skills/ldd-setup/SKILL.md`, `README.md`, `CONTEXT.md` | Validation checks template presence and `artifacts.research`; manual check that existing ticket `1` remains readable without a research artifact. | Slice 1 can run in parallel, but validation is cleaner after command surface exists. |
| 3. Research workflow and privacy contract | `/ldd:research` prompts for PM-grade inputs, reads code/docs read-only, writes sanitized research output, and reports readiness. | `skills/ldd-research/SKILL.md`, `skills/ldd-setup/assets/templates/research.md`, `.ldd/templates/research.md`, `CONTEXT.md` | Review hostile examples: weak input, split feature, non-PR, private financial input; grep checks for readiness labels and sensitivity handling. | Slice 1 and Slice 2. |
| 4. Scope adequacy gate and PM command gates | `/ldd:scope` rejects weak inputs before writing scope; PM commands state input standards and route to research/scope/elaboration as appropriate. | `skills/ldd-scope/SKILL.md`, `skills/ldd-elaborate/SKILL.md`, `skills/ldd-refine/SKILL.md`, related command adapters only if wording needs routing updates | Validation greps for `Input Quality Gate`; manual checks for scope refusing unclear problem/outcome and not reading code as design input. | Slice 3 for research labels and handoff language. |
| 5. Downstream phase gates and GitHub hierarchy safeguards | Design, plan, decompose, implement, verify, close, approve, next, and setup state their input standards and route gaps without mutating artifacts incorrectly. | `skills/ldd-design/SKILL.md`, `skills/ldd-plan/SKILL.md`, `skills/ldd-decompose/SKILL.md`, `skills/ldd-implement/SKILL.md`, `skills/ldd-verify/SKILL.md`, `skills/ldd-close/SKILL.md`, `skills/ldd-approve/SKILL.md`, `skills/ldd-next/SKILL.md`, `skills/ldd-setup/SKILL.md` | Validation greps for phase gates, SDD issue requirement before decomposition in GitHub mode, and copyable next command behavior; inspect approve/decompose hierarchy language. | Slices 1-4 establish the shared gate vocabulary. |
| 6. Documentation and package validation | User-facing docs, glossary, setup guidance, and validation script describe and enforce research, phase gates, privacy, and GitHub projection behavior. | `README.md`, `GEMINI.md`, `CONTEXT.md`, `docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md`, `scripts/validate-ldd-mvp.sh` | `./scripts/validate-ldd-mvp.sh`; `git diff --check`; review that docs do not imply GitHub is canonical. | Slices 1-5. |

Slice quality bar:

- Each slice names externally visible behavior or a concrete enabling outcome.
- Dependencies are explicit.
- Tests/checks are close to the changed behavior.
- No slice exists only to clean up unrelated files.

## Acceptance Criteria Traceability

| Acceptance criterion | Slice(s) | Verification |
| --- | --- | --- |
| Research prompts for source trigger, target users, problem evidence, current workflow, desired outcome, product importance, constraints, prior context, comparable behavior, non-goal candidates, and open questions. | 1, 3 | Inspect `skills/ldd-research/SKILL.md`; validation greps for core PM input prompts. |
| Research has full read-only visibility into repository, documentation, existing artifacts, and private/local context supplied by the human. | 3 | Inspect research rules for read-only visibility and no mutation outside research artifacts. |
| Shareable research output separates evidence, codebase facts, constraints, assumptions, risks, sensitivity handling, and open questions without becoming scope or design. | 2, 3 | Inspect `research.md` template and research quality bar. |
| Research readiness is one of ready for scope, blocked on more input, split recommended, or not a Product Requirement. | 3 | Validation greps for all readiness labels. |
| Scope refuses to write goals/non-goals when source inputs lack a clear problem or desired outcome. | 4 | Inspect `/ldd:scope` stop conditions and input gate; manual weak-input dry run. |
| Scope routes weak inputs to research or asks for missing source context. | 4 | Inspect scope rejection language and recommended next command. |
| Every LDD phase states the required input standard before writing or mutating its artifact. | 4, 5 | Validation greps for `Input Quality Gate` in every `skills/ldd-*/SKILL.md`. |
| Rejected inputs name the blocking gap and earliest LDD command that can fix it. | 4, 5 | Inspect phase gate rejection contracts; validation greps for earliest fixing command language. |
| Sensitive private inputs are consumed only as private intake; committed and GitHub-visible artifacts contain sanitized conclusions only. | 2, 3, 6 | Inspect privacy sections in research, templates, docs, and GitHub projection rules. |
| GitHub projection validation creates or updates shareable Product Requirement projection only after explicit human confirmation and states repo-local ledger is canonical. | 5, 6 | Inspect approve/decompose docs and setup templates; verify existing PRD issue `#1` and SDD issue `#2` remain projections of local ledger state. |

## Files / Modules

| File/module | Expected change | Reason |
| --- | --- | --- |
| `skills/ldd-research/SKILL.md` | New canonical command contract. | Adds research phase behavior, prompts, readiness labels, and privacy handling. |
| `skills/ldd-research/agents/openai.yaml` | New Codex/OpenAI skill metadata. | Makes research available through the Agent Skills package. |
| `commands/ldd/research.md` | New Claude command adapter. | Routes Claude slash command to canonical skill. |
| `commands/ldd/research.toml` | New Gemini command adapter. | Routes Gemini command to canonical skill. |
| `agent-skills.json` | Add `/ldd:research`. | Canonical package manifest. |
| `.claude-plugin/plugin.json` | Add research command adapter path. | Claude plugin install surface. |
| `gemini-extension.json` | Add `/ldd:research`. | Gemini extension install surface. |
| `skills/ldd-setup/assets/templates/research.md` and `.ldd/templates/research.md` | New research artifact template. | Durable sanitized research output. |
| `skills/ldd-setup/assets/templates/ledger.yml` and `.ldd/templates/ledger.yml` | Add optional `artifacts.research`. | Future tickets can record research state. |
| `skills/ldd-scope/SKILL.md` | Add input adequacy gate and research routing. | Prevent weak source inputs becoming scope. |
| `skills/ldd-elaborate/SKILL.md`, `skills/ldd-refine/SKILL.md` | Add PM input gates and repair routing. | Protect PRD handoff quality. |
| `skills/ldd-approve/SKILL.md`, `skills/ldd-design/SKILL.md`, `skills/ldd-plan/SKILL.md`, `skills/ldd-decompose/SKILL.md`, `skills/ldd-implement/SKILL.md`, `skills/ldd-verify/SKILL.md`, `skills/ldd-close/SKILL.md`, `skills/ldd-next/SKILL.md`, `skills/ldd-setup/SKILL.md` | Add input-quality gate sections and reject behavior. | Apply controls at each phase. |
| `README.md`, `GEMINI.md`, `CONTEXT.md` | Document research, input gates, privacy boundary, and GitHub projection. | User-facing workflow and glossary alignment. |
| `docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md` | Update package design reference. | Keep canonical design narrative current. |
| `scripts/validate-ldd-mvp.sh` | Require research files, manifest entries, templates, and gate language. | Prevent partial package updates. |

If implementation discovers different touch points, explain the variance in the implementation PR body.

## Test Strategy

- Unit tests:
  - Not applicable; this repository currently implements LDD as command contracts and templates, not executable application code.
- Integration/contract tests:
  - Run `./scripts/validate-ldd-mvp.sh`.
  - Extend validation to check the research command surface, setup templates, ledger field, readiness labels, privacy wording, and `Input Quality Gate` sections across all skills.
  - Keep JSON manifest validation for `agent-skills.json`, `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`, and `gemini-extension.json`.
- Regression tests:
  - Validate existing commands remain listed and installable.
  - Confirm existing ledgers without `artifacts.research` are still compatible by inspecting this ticket and archived tickets.
  - Confirm `/ldd:next` still emits a copyable command block.
  - Confirm GitHub issue numbering remains the approved ticket identity in GitHub tracker mode.
- Manual checks:
  - Review weak input route: `/ldd:scope` should refuse to write and recommend `/ldd:research`.
  - Review sensitive input route: research should summarize only sanitized implications and record redaction notes.
  - Review GitHub hierarchy: PRD issue `#1`, SDD issue `#2`, future decomposition child issues under SDD issue `#2`.
- Not testing, with reason:
  - No live Linear/Jira behavior; explicitly non-goal.
  - No automated GitHub issue creation in validation; external mutation remains human-confirmed and should not run in package validation.

Quality bar: tests prove package contract conformance and workflow behavior, not internal prose line-by-line.

## Review Checklist

- [x] The plan only implements the approved PRD and SDD.
- [x] Every PRD acceptance criterion maps to at least one slice and verification.
- [x] Every SDD interface/contract change appears in a slice.
- [x] Migration, compatibility, observability, and security/privacy work is included or explicitly not needed.
- [x] Slice order is dependency-safe and reviewable.
- [x] Any newly discovered architecture decision has been moved back to the SDD/ADR process.
