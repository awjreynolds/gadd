#!/usr/bin/env sh
set -eu

commands='setup next triage research scope elaborate refine approve design plan decompose implement verify close archive'

required_files='
agent-skills.json
README.md
CONTEXT.md
docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
docs/superpowers/specs/2026-05-15-gitnexus-code-intelligence-design.md
docs/superpowers/specs/2026-05-15-documentation-freshness-design.md
docs/superpowers/specs/2026-05-15-sdd-structure-section-design.md
docs/skills.md
docs/workflow.md
docs/package-model.md
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
gemini-extension.json
GEMINI.md
skills/gadd-setup/assets/templates/config.yml
skills/gadd-setup/assets/templates/work-item-ledger.yml
skills/gadd-setup/assets/templates/triage.md
skills/gadd-setup/assets/templates/research.md
skills/gadd-setup/assets/templates/prd.md
skills/gadd-setup/assets/templates/sdd.md
skills/gadd-setup/assets/templates/plan.md
skills/gadd-setup/assets/templates/plan.html
skills/gadd-setup/assets/templates/verification.md
skills/gadd-setup/assets/templates/issue-body-work-item.md
skills/gadd-setup/assets/templates/issue-body-prd.md
skills/gadd-setup/assets/templates/issue-body-sdd.md
skills/gadd-setup/assets/templates/pr-body-prd.md
skills/gadd-setup/assets/templates/pr-body-sdd-plan.md
skills/gadd-setup/assets/templates/pr-body-implementation.md
docs/assets/gadd-sdlc-workflow.svg
docs/assets/gadd-sdlc-workflow.png
'

for command in $commands; do
  required_files="$required_files
commands/gadd/$command.md
commands/gadd/$command.toml
skills/gadd-$command/SKILL.md
skills/gadd-$command/agents/openai.yaml"
done

for file in $required_files; do
  if [ ! -f "$file" ]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

for json_file in agent-skills.json .claude-plugin/plugin.json .claude-plugin/marketplace.json gemini-extension.json; do
  python3 -m json.tool "$json_file" >/dev/null
done

if [ -f gadd-skills.json ]; then
  echo "gadd-skills.json must not exist; use agent-skills.json" >&2
  exit 1
fi

if [ -d .gadd ]; then
  echo "repo-root .gadd must not exist; setup templates live under skills/gadd-setup/assets/templates" >&2
  exit 1
fi

grep -q '"canonicalSkillRoot": "skills"' agent-skills.json
grep -q '"stateSource": "docs/work-items/**/ledger.yml"' agent-skills.json
grep -q '"command": "/gadd:setup"' agent-skills.json
grep -q '"command": "/gadd:triage"' agent-skills.json
grep -q '"command": "/gadd:research"' agent-skills.json
grep -q '"command": "/gadd:approve"' agent-skills.json
grep -q '"command": "/gadd:decompose"' agent-skills.json
grep -q '"command": "/gadd:implement"' agent-skills.json
grep -q '"command": "/gadd:verify"' agent-skills.json
grep -q '"command": "/gadd:close"' agent-skills.json
grep -q '"command": "/gadd:archive"' agent-skills.json
grep -q '"pluginManifest": ".claude-plugin/plugin.json"' agent-skills.json
grep -q '"extensionManifest": "gemini-extension.json"' agent-skills.json
grep -q 'npx skills add awjreynolds/gadd' README.md
grep -q 'skills.sh-install-green' README.md
grep -q 'skills/gadd-setup/assets/templates/' README.md
grep -q 'docs/workflow.md' README.md
grep -q 'docs/skills.md' README.md
grep -q 'docs/package-model.md' README.md
grep -q '/gadd:triage' README.md
grep -q 'Work Item' README.md
grep -q 'unclassified intake' README.md
grep -q 'canonical executable contract' docs/skills.md
grep -q '/gadd:triage' docs/skills.md
grep -q 'Product Requirement lane' docs/skills.md
grep -q '/gadd:implement <work-item-id>' docs/skills.md
grep -q 'Software Engineering owns implementation quality' docs/skills.md
grep -q 'npx skills add awjreynolds/gadd' docs/package-model.md
grep -q 'Do not require repo-root `.gadd/` files' docs/package-model.md
grep -q 'docs/work-items/' docs/package-model.md
grep -q 'Unclassified intake' docs/workflow.md
grep -q 'triage outcome' docs/workflow.md
grep -q 'ready_for_implementation' docs/workflow.md
grep -q 'needs_sdd' docs/workflow.md
grep -q 'needs_prd' docs/workflow.md
grep -q -- '-> verification' docs/workflow.md
grep -q 'human-approved closure' docs/workflow.md
grep -q 'optional local archive cleanup' docs/workflow.md
grep -q 'GitHub is the first external-tracker dogfooding path' docs/workflow.md
grep -q 'Linear and Jira remain follow-on optional collaboration surfaces' docs/workflow.md
grep -q 'bounded shared-understanding gate' docs/workflow.md
grep -q 'GitNexus is the strongly recommended code-intelligence surface' docs/workflow.md
grep -q 'Implementation evidence must include documentation impact' docs/workflow.md
grep -q 'SDD templates include a required `## Structure` section' docs/workflow.md
grep -q 'header-file summary' docs/skills.md
grep -q 'Package Source Of Truth' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q '/gadd:approve' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q '/gadd:verify' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q 'GitHub-first Projection' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q 'GitNexus Code Intelligence Design' docs/superpowers/specs/2026-05-15-gitnexus-code-intelligence-design.md
grep -q 'The PRD is the parent product contract' docs/superpowers/specs/2026-05-15-gitnexus-code-intelligence-design.md
grep -q 'Documentation Freshness Design' docs/superpowers/specs/2026-05-15-documentation-freshness-design.md
grep -q 'Every implementation slice must account for documentation impact' docs/superpowers/specs/2026-05-15-documentation-freshness-design.md
grep -q 'SDD Structure Section Design' docs/superpowers/specs/2026-05-15-sdd-structure-section-design.md
grep -q 'header file' docs/superpowers/specs/2026-05-15-sdd-structure-section-design.md
grep -q 'approval-blocking' docs/superpowers/specs/2026-05-15-sdd-structure-section-design.md
grep -q 'A repo-local, machine-readable record' CONTEXT.md
grep -q 'Execution Context' CONTEXT.md
grep -q 'Bounded Shared Understanding Gate' CONTEXT.md
grep -q 'Verification' CONTEXT.md
grep -q 'Closure' CONTEXT.md
grep -q 'Ticket Promotion' CONTEXT.md
grep -q 'Work Item' CONTEXT.md
grep -q 'Triage Quality Loop' CONTEXT.md
grep -q 'External Issue' CONTEXT.md
grep -q 'Vertical Slice' CONTEXT.md
grep -q 'Agent Skills Manifest' CONTEXT.md
grep -q 'Standalone Skill Contract' CONTEXT.md
grep -q 'Parent Roll-up Closure' CONTEXT.md
grep -q 'GitHub-first Projection' CONTEXT.md

grep -q '"name": "gadd"' .claude-plugin/plugin.json
grep -q '"commands":' .claude-plugin/plugin.json
grep -q './commands/gadd/setup.md' .claude-plugin/plugin.json
grep -q './commands/gadd/triage.md' .claude-plugin/plugin.json
grep -q './commands/gadd/approve.md' .claude-plugin/plugin.json
grep -q './commands/gadd/decompose.md' .claude-plugin/plugin.json
grep -q './commands/gadd/implement.md' .claude-plugin/plugin.json
grep -q './commands/gadd/verify.md' .claude-plugin/plugin.json
grep -q './commands/gadd/close.md' .claude-plugin/plugin.json
grep -q './commands/gadd/archive.md' .claude-plugin/plugin.json
grep -q '"name": "gadd"' .claude-plugin/marketplace.json
grep -q '"name": "gadd"' .claude-plugin/marketplace.json
grep -q '"source": "./"' .claude-plugin/marketplace.json

grep -q '"name": "gadd"' gemini-extension.json
grep -q '"contextFileName": "GEMINI.md"' gemini-extension.json
grep -q '"/gadd:triage"' gemini-extension.json
grep -q '"/gadd:verify"' gemini-extension.json
grep -q '"/gadd:research"' gemini-extension.json
grep -q '"/gadd:approve"' gemini-extension.json
grep -q '"/gadd:close"' gemini-extension.json
grep -q '"/gadd:archive"' gemini-extension.json
grep -q 'Repo-local ledger is canonical' GEMINI.md

for command in $commands; do
  grep -q "/gadd:$command" "skills/gadd-$command/SKILL.md"
  grep -q 'Repo-local ledger is canonical' "skills/gadd-$command/SKILL.md"
  grep -q 'External mutations require human confirmation' "skills/gadd-$command/SKILL.md"
  grep -q 'display_name: "GADD ' "skills/gadd-$command/agents/openai.yaml"
  grep -q "gadd-$command" "commands/gadd/$command.md"
  grep -q 'canonical' "commands/gadd/$command.md"
  grep -q "description =" "commands/gadd/$command.toml"
  grep -q "prompt =" "commands/gadd/$command.toml"
  grep -q "/gadd:$command" "commands/gadd/$command.toml"
  grep -q "gadd-$command" "commands/gadd/$command.toml"
  grep -q 'Agent Skill' "commands/gadd/$command.toml"
  grep -q 'canonical' "commands/gadd/$command.toml"
done

grep -q '`.gadd/config.yml`' skills/gadd-setup/SKILL.md
grep -q 'GitNexus is the strongly recommended code-intelligence surface' skills/gadd-setup/SKILL.md

grep -q 'Read-only' skills/gadd-next/SKILL.md
grep -q 'It never mutates GitHub or local files' skills/gadd-next/SKILL.md
grep -q 'next: /gadd:decompose' skills/gadd-next/SKILL.md
grep -q 'execution_context' skills/gadd-next/SKILL.md
grep -q 'derive equivalent state' skills/gadd-next/SKILL.md
grep -q 'next: /gadd:verify <work-item-id>' skills/gadd-next/SKILL.md
grep -q 'next: /gadd:close <work-item-id>' skills/gadd-next/SKILL.md
grep -q 'next: /gadd:close <parent-work-item-id>' skills/gadd-next/SKILL.md
grep -q 'closure.status' skills/gadd-next/SKILL.md
grep -q 'optional_cleanup_command: /gadd:archive <parent-work-item-id>' skills/gadd-next/SKILL.md
grep -q 'optional cleanup, not as `next_command`' skills/gadd-next/SKILL.md
grep -q 'next_human_action' skills/gadd-next/SKILL.md
grep -q '/gadd:approve <work-item-id>' skills/gadd-next/SKILL.md
grep -q 'does not perform mutations' skills/gadd-next/SKILL.md
grep -q 'Do not infer them from the conversation' skills/gadd-next/SKILL.md
grep -q 'implementation PR state is checked' skills/gadd-next/SKILL.md
grep -q 'Verification owns recording observed merge evidence' skills/gadd-next/SKILL.md
grep -q 'Never treat a conversational claim such as "merged" as merge evidence' skills/gadd-next/SKILL.md
grep -q 'Approval Gate Detection' skills/gadd-next/SKILL.md
grep -q 'copyable command block containing only the next command' skills/gadd-next/SKILL.md
grep -Eq 'execution_context\.phase.*refine' skills/gadd-next/SKILL.md
if grep -q 'artifacts.prd.status: draft.*approved_artifacts.prd' skills/gadd-next/SKILL.md skills/gadd-approve/SKILL.md; then
  echo "draft PRDs must not be treated as approval-ready before refinement" >&2
  exit 1
fi

grep -q 'Approve exactly one PRD, SDD, or plan gate' skills/gadd-approve/SKILL.md
grep -q 'Plan Approval Workflow' skills/gadd-approve/SKILL.md
grep -q 'Plan candidate' skills/gadd-approve/SKILL.md
grep -q 'next_command: /gadd:decompose 123' skills/gadd-approve/SKILL.md
grep -q 'exactly one approval gate is active' skills/gadd-approve/SKILL.md
grep -q 'GitHub is the first external tracker dogfooding path' skills/gadd-approve/SKILL.md
grep -q 'GitHub issue number as the stable ticket ID' skills/gadd-approve/SKILL.md
grep -q 'Do not invent or preserve an `GADD-0004` style ID in GitHub tracker mode' skills/gadd-approve/SKILL.md
grep -q 'GitHub SDD issue' skills/gadd-approve/SKILL.md
grep -q 'PRD #<prd_issue_number> SDD:' skills/gadd-approve/SKILL.md
grep -q 'SDD Work Item projection' skills/gadd-approve/SKILL.md
grep -q 'missing or stale `## Structure`' skills/gadd-approve/SKILL.md
grep -q 'structure summary' skills/gadd-approve/SKILL.md

grep -q 'do not read the codebase as a design input' skills/gadd-scope/SKILL.md
grep -q 'This is a bounded shared understanding gate' skills/gadd-scope/SKILL.md
grep -q 'Existing promoted Product Requirement tickets do not block new scoping work' skills/gadd-scope/SKILL.md
grep -q 'Keep at most one active local draft' skills/gadd-scope/SKILL.md
grep -q 'create a new draft' skills/gadd-scope/SKILL.md
grep -q 'do not read the codebase as a design input' skills/gadd-elaborate/SKILL.md
grep -q 'This is a bounded shared understanding gate' skills/gadd-elaborate/SKILL.md
grep -q 'do not read the codebase as a design input' skills/gadd-refine/SKILL.md
grep -q 'This is a bounded shared understanding gate' skills/gadd-refine/SKILL.md
grep -q 'explicit uncertainties' skills/gadd-scope/SKILL.md
grep -q 'explicit uncertainties' skills/gadd-elaborate/SKILL.md
grep -q 'explicit uncertainties' skills/gadd-refine/SKILL.md
grep -q 'write or update `## Structure`' skills/gadd-design/SKILL.md
grep -q 'header-file summary' skills/gadd-design/SKILL.md
grep -q 'keep it synchronized' skills/gadd-design/SKILL.md

grep -q 'draft_directory: docs/work-items/_drafts' skills/gadd-setup/assets/templates/config.yml
grep -q 'archive_directory: docs/work-items/_archive' skills/gadd-setup/assets/templates/config.yml
grep -q 'GitHub-first managed projections' skills/gadd-setup/assets/templates/config.yml
grep -q 'Linear and Jira are follow-on collaboration surfaces' skills/gadd-setup/assets/templates/config.yml
grep -q 'code_intelligence:' skills/gadd-setup/assets/templates/config.yml
grep -q 'preferred_tool: gitnexus' skills/gadd-setup/assets/templates/config.yml
grep -q 'required_for_triage: true' skills/gadd-setup/assets/templates/config.yml
grep -q 'labels:' skills/gadd-setup/assets/templates/config.yml
grep -q 'gadd:needs-info' skills/gadd-setup/assets/templates/config.yml
grep -q 'schema_version: 1' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'work_item:' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'type: external_issue_intake' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'state: needs_info' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'external:' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'triage:' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q '# Triage Narrative' skills/gadd-setup/assets/templates/triage.md
grep -q 'What we have established' skills/gadd-setup/assets/templates/triage.md
grep -q 'What we still need' skills/gadd-setup/assets/templates/triage.md
grep -q '# Work Item:' skills/gadd-setup/assets/templates/issue-body-work-item.md
grep -q '# GADD Research' skills/gadd-setup/assets/templates/research.md
grep -q 'Readiness Decision' skills/gadd-setup/assets/templates/research.md
grep -q 'Sensitivity Handling' skills/gadd-setup/assets/templates/research.md
grep -q 'GitNexus / Code Intelligence' skills/gadd-setup/assets/templates/research.md
grep -q 'Explicit Uncertainties' skills/gadd-setup/assets/templates/research.md
grep -q 'external_body_hash:' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'managed_body_version:' skills/gadd-setup/assets/templates/work-item-ledger.yml
grep -q 'current_gate: scope' skills/gadd-setup/assets/templates/work-item-ledger.yml
if grep -q 'current_gate: prd_approval' skills/gadd-setup/assets/templates/work-item-ledger.yml; then
  echo "new draft ledger template must not start at PRD approval gate" >&2
  exit 1
fi
grep -q '# PRD:' skills/gadd-setup/assets/templates/prd.md
grep -q 'Product Manager artifact' skills/gadd-setup/assets/templates/prd.md
grep -q 'PRD Handoff Checklist' skills/gadd-setup/assets/templates/prd.md
grep -q 'No implementation decisions' skills/gadd-setup/assets/templates/prd.md
grep -q 'avoid prescribing command mechanics' skills/gadd-setup/assets/templates/prd.md
grep -q 'Avoid: Gherkin/Cucumber syntax here' skills/gadd-setup/assets/templates/prd.md
grep -q 'Given/When/Then' skills/gadd-setup/assets/templates/prd.md
grep -q '# Software Design Document:' skills/gadd-setup/assets/templates/sdd.md
grep -q '## Structure' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Design intent:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Primary components / modules:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Responsibility boundaries:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Key interfaces / contracts:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Data or control flow:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Explicit non-changes:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Detail map:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Quality bar:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'ADR threshold:' skills/gadd-setup/assets/templates/sdd.md
grep -q 'Review Checklist' skills/gadd-setup/assets/templates/sdd.md
grep -q '# Implementation Plan:' skills/gadd-setup/assets/templates/plan.md
grep -q 'Acceptance Criteria Traceability' skills/gadd-setup/assets/templates/plan.md
grep -q 'Slice quality bar:' skills/gadd-setup/assets/templates/plan.md
grep -q 'Review load' skills/gadd-setup/assets/templates/plan.md
grep -q 'Documentation Impact' skills/gadd-setup/assets/templates/plan.md
grep -q 'Documentation impact is explicit' skills/gadd-setup/assets/templates/plan.md
grep -q '200 changed files' skills/gadd-setup/assets/templates/plan.md
grep -q 'must not introduce new architecture decisions' skills/gadd-setup/assets/templates/plan.md
grep -q '## Problem Statement' skills/gadd-setup/assets/templates/issue-body-prd.md
grep -q 'GitHub issue projection' skills/gadd-setup/assets/templates/issue-body-prd.md
grep -q '## GADD Links' skills/gadd-setup/assets/templates/issue-body-prd.md
grep -q '## Parent Product Requirement' skills/gadd-setup/assets/templates/issue-body-sdd.md
grep -q '# PRD {prd_issue} SDD: {title}' skills/gadd-setup/assets/templates/issue-body-sdd.md
grep -q 'GitHub child issue projection for SDD visibility' skills/gadd-setup/assets/templates/issue-body-sdd.md
grep -q 'implementation child issues created by decomposition are children of this SDD issue' skills/gadd-setup/assets/templates/issue-body-sdd.md
grep -q 'Decompose only from an approved plan' skills/gadd-decompose/SKILL.md
grep -q 'vertical slices' skills/gadd-decompose/SKILL.md
grep -q 'cognitive-load budget' skills/gadd-decompose/SKILL.md
grep -q '200 changed files' skills/gadd-decompose/SKILL.md
grep -q 'focused human review' skills/gadd-decompose/SKILL.md
grep -q 'Preview Before Creation' skills/gadd-decompose/SKILL.md
grep -q 'Documentation impact' skills/gadd-decompose/SKILL.md
grep -q 'independently grabbable' skills/gadd-decompose/SKILL.md
grep -q 'SDD #<sdd_issue_number> Slice <slice-number>:' skills/gadd-decompose/SKILL.md
grep -q "GADD's standalone child issue shape" skills/gadd-decompose/SKILL.md
grep -q 'external contribution' skills/gadd-decompose/SKILL.md
grep -q 'projected as GitHub issues' skills/gadd-decompose/SKILL.md
grep -q 'native GitHub sub-issue' skills/gadd-decompose/SKILL.md
grep -q 'POST /repos/{owner}/{repo}/issues/{sdd_issue_number}/sub_issues' skills/gadd-decompose/SKILL.md
grep -q 'sub_issue_id' skills/gadd-decompose/SKILL.md
grep -q 'body-only linked issue fallback requires a separate explicit human confirmation' skills/gadd-decompose/SKILL.md
grep -q 'grandchildren of the PRD issue' skills/gadd-decompose/SKILL.md
grep -q 'Built-in TDD Loop' skills/gadd-implement/SKILL.md
grep -q 'Run this loop directly from this skill' skills/gadd-implement/SKILL.md
grep -q 'Write the smallest focused test' skills/gadd-implement/SKILL.md
grep -q 'Run the focused test and confirm it fails' skills/gadd-implement/SKILL.md
grep -q 'approved PRD, SDD, and plan boundaries' skills/gadd-implement/SKILL.md
grep -q 'closure.status: verification_required' skills/gadd-implement/SKILL.md
grep -q 'Do not archive Work Items' skills/gadd-implement/SKILL.md
grep -q 'Do not close external Work Item projections' skills/gadd-implement/SKILL.md
grep -q 'implementation PR is a managed projection' skills/gadd-implement/SKILL.md
grep -q 'documentation impact status and paths or rationale' skills/gadd-implement/SKILL.md
grep -q 'documentation impact is `blocked`' skills/gadd-implement/SKILL.md
grep -q 'child-ticket closure' skills/gadd-verify/SKILL.md
grep -q 'not a general repository healthcheck' skills/gadd-verify/SKILL.md
grep -q 'documentation impact evidence' skills/gadd-verify/SKILL.md
grep -q 'GitNexus may be used for optional blast-radius' skills/gadd-verify/SKILL.md
grep -q 'implementation completion' skills/gadd-verify/SKILL.md
grep -q 'closure.status' skills/gadd-verify/SKILL.md
grep -q 'passed | failed | override_required' skills/gadd-verify/SKILL.md
grep -q 'approved parent PRD, approved parent SDD, approved parent plan' skills/gadd-verify/SKILL.md
grep -q 'scope/design/plan drift' skills/gadd-verify/SKILL.md
grep -q 'external ticket drift is unresolved' skills/gadd-verify/SKILL.md
grep -q 'Implementation PR State Rule' skills/gadd-verify/SKILL.md
grep -q 'implementation PR state is externally checked' skills/gadd-verify/SKILL.md
grep -q 'Never treat a conversational claim such as "merged" as merge evidence' skills/gadd-verify/SKILL.md
grep -q 'records the observed `mergedAt` and merge commit as evidence' skills/gadd-verify/SKILL.md
grep -q 'verification.md' skills/gadd-verify/SKILL.md
grep -q 'Do not mutate external trackers' skills/gadd-verify/SKILL.md
grep -q 'Apply closure for one verified child work item' skills/gadd-close/SKILL.md
grep -q 'artifacts.verification.status: passed' skills/gadd-close/SKILL.md
grep -q 'closure.status: verified' skills/gadd-close/SKILL.md
grep -q 'External mutations require human confirmation' skills/gadd-close/SKILL.md
grep -q 'does not archive local ticket files' skills/gadd-close/SKILL.md
grep -q 'Do not archive or move local ticket directories' skills/gadd-close/SKILL.md
grep -q 'Parent Roll-up Workflow' skills/gadd-close/SKILL.md
grep -q 'GitHub issue closure is the expected external close projection' skills/gadd-close/SKILL.md
grep -q 'Do not rely on GitHub auto-close keywords' skills/gadd-close/SKILL.md
grep -q 'every child is verified and closeable' skills/gadd-close/SKILL.md
grep -q 'Keep the parent directory in place' skills/gadd-close/SKILL.md
grep -q 'parent close requested while any child is not verified and closeable' skills/gadd-close/SKILL.md
grep -q 'Move already-closed local Work Item packages' skills/gadd-archive/SKILL.md
grep -q 'storage hygiene only' skills/gadd-archive/SKILL.md
grep -q 'No external tracker writes are allowed' skills/gadd-archive/SKILL.md
grep -q 'closure.status: closed | externally_closed | archived' skills/gadd-archive/SKILL.md
grep -q 'archive_directory' skills/gadd-archive/SKILL.md
grep -q 'child_archived' skills/gadd-archive/SKILL.md
grep -q 'parent_archived' skills/gadd-archive/SKILL.md
grep -q 'standard PM inputs' skills/gadd-research/SKILL.md
grep -q 'full read-only' skills/gadd-research/SKILL.md
grep -q 'ready_for_scope' skills/gadd-research/SKILL.md
grep -q 'blocked_on_more_input' skills/gadd-research/SKILL.md
grep -q 'split_recommended' skills/gadd-research/SKILL.md
grep -q 'not_a_product_requirement' skills/gadd-research/SKILL.md
grep -q 'financially sensitive' skills/gadd-research/SKILL.md
for command in $commands; do
  grep -q 'Input Quality Gate' "skills/gadd-$command/SKILL.md"
  grep -q 'earliest GADD command' "skills/gadd-$command/SKILL.md"
done
grep -q 'Verification status: pending | passed | failed | override_required' skills/gadd-setup/assets/templates/verification.md
grep -q 'Boundary: child-ticket closure only, not repository health' skills/gadd-setup/assets/templates/verification.md
grep -q 'External tracker drift: pending' skills/gadd-setup/assets/templates/verification.md
grep -q 'Human confirmation required before external mutation: yes' skills/gadd-setup/assets/templates/verification.md
grep -q 'Product Boundary' skills/gadd-setup/assets/templates/pr-body-prd.md
grep -q 'Handoff Checklist' skills/gadd-setup/assets/templates/pr-body-prd.md
grep -q 'Traceability Checks' skills/gadd-setup/assets/templates/pr-body-sdd-plan.md
grep -q 'GitHub-first managed projection for SDD and plan review' skills/gadd-setup/assets/templates/pr-body-sdd-plan.md
grep -q 'Does this implementation follow the approved plan?' skills/gadd-setup/assets/templates/pr-body-implementation.md
grep -q 'GitHub-first managed projection for implementation review' skills/gadd-setup/assets/templates/pr-body-implementation.md
grep -q 'Plan Conformance' skills/gadd-setup/assets/templates/pr-body-implementation.md
grep -q 'Treat <code>plan.md</code> as the source of truth' skills/gadd-setup/assets/templates/plan.html

grep -q 'approved triage outcome' skills/gadd-design/SKILL.md
grep -q 'Raw external issues must route through /gadd:triage' skills/gadd-design/SKILL.md
grep -q 'engineering_change' skills/gadd-approve/SKILL.md
grep -q 'without requiring an approved PRD' skills/gadd-approve/SKILL.md
grep -q 'ready_for_implementation' skills/gadd-next/SKILL.md
grep -q 'needs_sdd' skills/gadd-next/SKILL.md
grep -q 'needs_prd' skills/gadd-next/SKILL.md
grep -q 'bug_fix' skills/gadd-implement/SKILL.md
grep -q 'task' skills/gadd-implement/SKILL.md
grep -q 'approved triage outcome' skills/gadd-implement/SKILL.md
grep -q 'verify Work Items, not only implementation slices' skills/gadd-verify/SKILL.md
grep -q 'Work Item archive directory' skills/gadd-archive/SKILL.md

grep -q 'artifact quality guidance' skills/gadd-setup/SKILL.md
grep -q 'GitHub-first tracker readiness' skills/gadd-setup/SKILL.md
grep -q 'PRD template as a quality contract' skills/gadd-scope/SKILL.md
grep -q 'should not prescribe exact command behavior' skills/gadd-elaborate/SKILL.md
grep -q 'Preserve the Product Manager boundary' skills/gadd-refine/SKILL.md
grep -q 'Run /gadd:approve <work-item-id> to approve this PRD' skills/gadd-refine/SKILL.md
grep -q 'GitHub issue number as the promoted ticket ID' skills/gadd-refine/SKILL.md
grep -q "SDD template's quality bar" skills/gadd-design/SKILL.md
grep -q 'SDD approval must be recorded through `/gadd:approve <work-item-id>`' skills/gadd-design/SKILL.md
grep -q "plan template's traceability" skills/gadd-plan/SKILL.md
grep -q 'Stop at explicit plan approval through `/gadd:approve <work-item-id>`' skills/gadd-plan/SKILL.md
grep -q 'next_command: /gadd:approve <work-item-id>' skills/gadd-plan/SKILL.md
grep -q 'plan exists but is not approved' skills/gadd-next/SKILL.md
grep -q 'repo-local ledger as canonical workflow state' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md

if grep -R -n -E 'Pocock|to-issues|to-prd|/tdd|/setup-matt|Superpowers|external TDD skill required|requires? an external .*skill' skills commands README.md CONTEXT.md docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md GEMINI.md agent-skills.json; then
  echo "GADD command package must not depend on external skills" >&2
  exit 1
fi

if rg -n 'GADD ticket|docs/tickets|child ticket|parent ticket|ticket directory|ticket-id|<ticket>' README.md CONTEXT.md docs skills commands agent-skills.json gemini-extension.json >/tmp/gadd-ticket-language.txt; then
  echo "legacy ticket language remains outside external tracker context:" >&2
  cat /tmp/gadd-ticket-language.txt >&2
  exit 1
fi

echo "GADD MVP installable skills validated"
