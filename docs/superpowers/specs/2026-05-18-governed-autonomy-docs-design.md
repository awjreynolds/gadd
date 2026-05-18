# Governed Autonomy Docs Design

**Date:** 2026-05-18
**Status:** ready for user review before implementation planning
**Context:** defining a broader Governed Autonomy documentation surface in the GADD repository without narrowing the philosophy to software delivery

## Thesis

Governed Autonomy is a business-process discipline for the AI transformation era.

Its core claim is:

> Organizations can delegate more work to autonomous systems only when human accountability, authority, scope, evidence, escalation, approval, and closure boundaries remain explicit.

Governed Autonomy should be presented as a practical synthesis, not as a claim of invention. It draws from existing disciplines: business process management, business analysis, process improvement, Responsible AI, AI governance, operating model design, risk management, human oversight, auditability, and agentic AI governance. Its useful contribution is the lens it gives organizations under AI autonomy pressure: redesign the business process so autonomous systems can act without dissolving accountability, evidence, escalation, and approval.

GADD is one concrete application of that philosophy to software delivery. The Governed Autonomy docs must therefore explain the general philosophy first, then show GADD as a case study rather than defining Governed Autonomy as software-specific.

The documentation should be accessible enough for an ELI5 reader and serious enough for business analysts, process-improvement practitioners, transformation leads, COOs, CIOs, local-government digital leaders, enterprise buyers, and senior stakeholders evaluating uncontrolled AI business risk.

## Problem

AI transformation is often framed as task automation: can an AI answer this question, draft this document, make this decision, update this system, or perform this workflow step?

That framing is too narrow. The business risk is not only bad model output. The larger risk is uncontrolled AI changing how work flows through an organization without accountable control.

Common failure modes include:

- Chat becomes the control plane for important work.
- An AI system moves from advice to action without explicit authority.
- Analyst, operator, reviewer, approver, and auditor roles collapse into one session.
- Evidence trails lag behind decisions and actions.
- Humans are asked to approve too late or without usable context.
- Autonomous actions span multiple systems without a clear source of truth.
- No named owner can explain, defend, or reverse an AI-driven action.
- Narrow requests expand into broader operational change at machine speed.
- Governance is added after the automation exists rather than designed into the process.

Governed Autonomy should be positioned as mitigation for those business risks.

## Documentation Architecture

Create a dedicated documentation directory:

```text
docs/governed-autonomy/
  README.md
  operating-model.md
  process-assessment.md
  uncontrolled-ai-risk-patterns.md
  case-study-gadd.md
  related-landscape.md
  references.md
  assets/
```

Update existing docs:

- `README.md`: add a concise link that introduces Governed Autonomy as the broader philosophy and GADD as the software-delivery methodology.
- `CONTEXT.md`: broaden the opening definition so Governed Autonomy is not software-only.
- `docs/workflow.md`: add a light pointer back to the Governed Autonomy docs while keeping the workflow page focused on GADD mechanics.

Do not use GitHub Wiki as the canonical surface. Wiki is enabled for the repository, but this material should stay versioned with the code and docs. Do not enable GitHub Pages in this first pass; the repository does not currently have Pages configured.

## Page Contracts

### `README.md`

This is the entry point for the Governed Autonomy directory.

It should start with an ELI5 section:

> Governed Autonomy means letting AI or automated systems help do work while making sure people still decide what matters, know what happened, can inspect the evidence, and approve important steps.

After the ELI5 section, the page should become more substantial:

- Explain Governed Autonomy as a business-process discipline.
- Make the unit of analysis the business process, not the industry.
- Explain why "can AI do this task?" is the wrong first question.
- Reframe the question as: "Can this process safely delegate this step under these boundaries, with this evidence and escalation path?"
- Connect the discipline to business analysis, process improvement, operating model design, governance, risk management, and change management.
- Introduce GADD as the first documented case study in this repository.

### `operating-model.md`

This page defines the reusable operating model for Governed Autonomy.

It should cover:

- Roles and decision rights.
- Authority boundaries.
- Input quality gates.
- Scope and execution boundaries.
- Risk and blast-radius classification.
- Evidence requirements.
- Escalation paths.
- Approval points.
- State, traceability, and auditability.
- Proportional governance: stronger controls for higher-risk process steps.
- Projection into existing systems rather than replacing them.

The page should state the central value proposition:

> The value is not that AI does work. The value is that autonomous execution becomes governable at organizational scale.

### `process-assessment.md`

This page gives a business-analysis and process-improvement lens for applying Governed Autonomy.

It should help a reader assess a process before introducing or expanding AI autonomy:

- Map the as-is process.
- Identify handoffs, decision rights, controls, and existing evidence.
- Identify where AI is currently used or proposed.
- Classify process steps by autonomy risk.
- Define the to-be process.
- Decide which steps can be assisted, recommended, drafted, executed with approval, or executed within bounded limits.
- Specify what evidence is required at each step.
- Define human escalation and override points.
- Define how outcomes will be measured.

It should avoid grounding the philosophy in any one industry. Process examples can include approvals, case handling, procurement, compliance review, incident response, service requests, change management, planning, customer/citizen support, and internal operations.

### `uncontrolled-ai-risk-patterns.md`

This page names the behaviors Governed Autonomy is meant to mitigate.

Required risk patterns:

- Chat as a control plane.
- Unbounded delegation.
- Role collapse.
- Evidence drift.
- Approval theater.
- Tool sprawl.
- Accountability gaps.
- Scope creep at machine speed.
- Post-hoc governance.

Each pattern should include:

- What the pattern looks like.
- Why it creates business risk.
- What a Governed Autonomy response would require.

This page is central to the positioning. It gives serious readers a concrete reason to care.

### `case-study-gadd.md`

This page treats GADD as a case study, not as the whole definition of Governed Autonomy.

It should map Governed Autonomy principles onto the software-delivery process:

- Business process: intake to verified closure.
- Roles: PM, EM/Tech Lead, SE, Engineering Review.
- Boundaries: PRD, SDD, plan, implementation, verification, closure.
- Evidence: repo-local ledgers, artifacts, checks, verification reports, approval records.
- Existing systems: GitHub, Jira, Linear, Asana, and similar planning tools as projection surfaces where supported or targeted.
- Risk mitigation: repo-local ledger beats chat as control plane; phase gates reduce role collapse; artifacts reduce evidence drift; `/gadd:approve` keeps approvals explicit; external projections reduce planning-system drift.

The page must be clear that GADD currently applies Governed Autonomy to software delivery. It must not claim that GADD supports non-software business processes today.

### `related-landscape.md`

This page positions Governed Autonomy near existing AI and process-governance work.

It should discuss adjacent areas:

- Responsible AI.
- AI governance.
- AI management systems.
- Agentic AI governance.
- Agentic business process management.
- AI operating models.
- Business process improvement.
- Human oversight and accountability.

This page should be explicit that Governed Autonomy is not trying to replace these disciplines or claim their ideas as new. It is a practical lens for applying them to business processes where autonomous systems are beginning to perform work.

The distinction should be:

> Governed Autonomy centers the business process as the unit of design. It asks how autonomous systems participate in a process without dissolving human accountability, evidence, escalation, and approval boundaries.

The page should avoid claiming exclusive ownership of the phrase "Governed Autonomy." The term already appears in current AI-governance and finance-oriented contexts.

### `references.md`

This page should collect annotated references used by the landscape page and the operating-model framing.

Initial reference areas:

- ISO/IEC 42001 for AI management systems.
- OECD AI Principles for human-centered values, transparency, robustness, accountability, and governance.
- NIST AI Risk Management Framework for AI risk framing and governance vocabulary.
- IBM's agentic AI governance writing for action governance, boundaries, ownership, monitoring, and escalation.
- Agentic business process management research for autonomy inside business processes.
- Public-sector AI-agent governance research for oversight, auditability, operational visibility, and interdepartmental coordination.
- Vendor operating-model examples where they discuss AI agents anchored in business processes, governance, approval flows, identity, compliance, and auditability.

References should be summarized briefly and linked. Do not copy long source passages.

## Visual Asset Requirements

The first implementation pass should include explanatory diagrams, not decorative images.

Create source-controlled assets under:

```text
docs/governed-autonomy/assets/
```

Required visuals:

1. **Governed Autonomy Loop**
   Process mapping -> delegation boundary -> autonomous execution -> evidence -> escalation or approval -> measured outcome.

2. **Uncontrolled AI vs Governed Autonomy**
   A side-by-side comparison showing uncontrolled task automation, unclear ownership, weak audit trails, and tool sprawl on one side; process, role, boundary, evidence, escalation, and approval on the other.

3. **Business Process Autonomy Ladder**
   Assist -> recommend -> draft -> execute with approval -> execute within bounded limits -> autonomous with monitoring.

4. **GADD Case Study Map**
   Governed Autonomy principles mapped onto GADD artifacts and handoffs.

Prefer maintainable diagram sources such as Mermaid or SVG source committed with rendered static assets. The diagrams should be simple enough to explain principles quickly and polished enough for serious stakeholders.

## Claims And Boundaries

The docs may claim:

- Governed Autonomy is a general business-process philosophy for AI transformation.
- Governed Autonomy is a synthesis lens that applies existing governance, process, risk, and operating-model disciplines to autonomous systems.
- GADD is a software-delivery application of Governed Autonomy.
- The business process, not the industry, is the main unit of analysis.
- Uncontrolled AI creates business risk when autonomy changes work without accountable process control.
- Existing systems should usually remain collaboration and projection surfaces rather than being replaced by a new AI tool.

The docs must not claim:

- GADD supports non-software workflows today.
- Governed Autonomy is a wholly new invention or replacement for Responsible AI, BPM, operating model design, risk management, or AI governance.
- Governed Autonomy is an exclusively owned term.
- GitHub Pages or Wiki is the canonical documentation surface.
- Jira, Linear, Asana, or government-system integrations are validated beyond the existing maturity model.
- AI autonomy is safe because a human approval step exists somewhere in the workflow.

## Non-Goals

- Do not build a documentation site.
- Do not enable GitHub Pages.
- Do not move canonical docs into GitHub Wiki.
- Do not create a services or consulting landing page.
- Do not write industry-specific Governed Autonomy implementations in this pass.
- Do not add decorative AI-generated images.
- Do not modify GADD command behavior.
- Do not change workflow templates or ledgers.

## Verification

Implementation should verify:

- Markdown links are valid where practical.
- `scripts/validate-gadd-docs.py` passes.
- The full `scripts/validate-gadd-mvp.sh` passes unless it is too broad for a docs-only change.
- Grep confirms Governed Autonomy is not accidentally narrowed back to software only in the new docs.
- References are attributed and summarized without long copied passages.
- The GADD case study clearly states that GADD is one implementation of the broader philosophy.

## Acceptance Criteria

- A non-software reader can understand Governed Autonomy without knowing GADD.
- A business analyst or transformation lead can see how the philosophy maps to process assessment and redesign.
- A senior stakeholder can understand the business risk of uncontrolled AI.
- A GADD reader can understand why GADD's strict handoffs are a case study in Governed Autonomy.
- The docs include a related-landscape and references surface so the concept feels serious and situated.
- The docs include an explicit visual plan that favors explanatory diagrams over decorative imagery.
- The root README and existing GADD docs point to the new Governed Autonomy directory without overclaiming support outside software delivery.
