#!/usr/bin/env sh
set -eu

commands='setup next research scope elaborate refine approve design plan decompose implement verify close archive'

required_files='
agent-skills.json
README.md
CONTEXT.md
docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
.claude-plugin/plugin.json
.claude-plugin/marketplace.json
gemini-extension.json
GEMINI.md
skills/ldd-setup/assets/templates/config.yml
skills/ldd-setup/assets/templates/ledger.yml
skills/ldd-setup/assets/templates/research.md
skills/ldd-setup/assets/templates/prd.md
skills/ldd-setup/assets/templates/sdd.md
skills/ldd-setup/assets/templates/plan.md
skills/ldd-setup/assets/templates/plan.html
skills/ldd-setup/assets/templates/issue-body-prd.md
skills/ldd-setup/assets/templates/issue-body-sdd.md
skills/ldd-setup/assets/templates/issue-body-child.md
skills/ldd-setup/assets/templates/pr-body-prd.md
skills/ldd-setup/assets/templates/pr-body-sdd-plan.md
skills/ldd-setup/assets/templates/pr-body-implementation.md
skills/ldd-setup/assets/templates/verification.md
'

for command in $commands; do
  required_files="$required_files
commands/ldd/$command.md
commands/ldd/$command.toml
skills/ldd-$command/SKILL.md
skills/ldd-$command/agents/openai.yaml"
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

if [ -f ldd-skills.json ]; then
  echo "ldd-skills.json must not exist; use agent-skills.json" >&2
  exit 1
fi

grep -q '"canonicalSkillRoot": "skills"' agent-skills.json
grep -q '"command": "/ldd:setup"' agent-skills.json
grep -q '"command": "/ldd:research"' agent-skills.json
grep -q '"command": "/ldd:approve"' agent-skills.json
grep -q '"command": "/ldd:decompose"' agent-skills.json
grep -q '"command": "/ldd:implement"' agent-skills.json
grep -q '"command": "/ldd:verify"' agent-skills.json
grep -q '"command": "/ldd:close"' agent-skills.json
grep -q '"command": "/ldd:archive"' agent-skills.json
grep -q '"pluginManifest": ".claude-plugin/plugin.json"' agent-skills.json
grep -q '"extensionManifest": "gemini-extension.json"' agent-skills.json
grep -q 'agent-skills.json' README.md
grep -q 'Installed Codex skills are local copies' README.md
grep -q -- '-> verification' README.md
grep -q 'human-approved closure' README.md
grep -q 'optional local archive cleanup' README.md
grep -q 'GitHub is the first external-tracker dogfooding path' README.md
grep -q 'Linear and Jira remain follow-on optional collaboration surfaces' README.md
grep -q 'bounded shared-understanding gate' README.md
grep -q 'Package Source Of Truth' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q '/ldd:approve' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q '/ldd:verify' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q 'GitHub-first Projection' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md
grep -q 'A repo-local, machine-readable record' CONTEXT.md
grep -q 'Execution Context' CONTEXT.md
grep -q 'Bounded Shared Understanding Gate' CONTEXT.md
grep -q 'Verification' CONTEXT.md
grep -q 'Closure' CONTEXT.md
grep -q 'Ticket Promotion' CONTEXT.md
grep -q 'Vertical Slice' CONTEXT.md
grep -q 'Agent Skills Manifest' CONTEXT.md
grep -q 'Standalone Skill Contract' CONTEXT.md
grep -q 'Parent Roll-up Closure' CONTEXT.md
grep -q 'GitHub-first Projection' CONTEXT.md

grep -q '"name": "ldd"' .claude-plugin/plugin.json
grep -q '"commands":' .claude-plugin/plugin.json
grep -q './commands/ldd/setup.md' .claude-plugin/plugin.json
grep -q './commands/ldd/approve.md' .claude-plugin/plugin.json
grep -q './commands/ldd/decompose.md' .claude-plugin/plugin.json
grep -q './commands/ldd/implement.md' .claude-plugin/plugin.json
grep -q './commands/ldd/verify.md' .claude-plugin/plugin.json
grep -q './commands/ldd/close.md' .claude-plugin/plugin.json
grep -q './commands/ldd/archive.md' .claude-plugin/plugin.json
grep -q '"name": "ledger-driven-development"' .claude-plugin/marketplace.json
grep -q '"name": "ldd"' .claude-plugin/marketplace.json
grep -q '"source": "./"' .claude-plugin/marketplace.json

grep -q '"name": "ledger-driven-development"' gemini-extension.json
grep -q '"contextFileName": "GEMINI.md"' gemini-extension.json
grep -q '"/ldd:verify"' gemini-extension.json
grep -q '"/ldd:research"' gemini-extension.json
grep -q '"/ldd:approve"' gemini-extension.json
grep -q '"/ldd:close"' gemini-extension.json
grep -q '"/ldd:archive"' gemini-extension.json
grep -q 'Repo-local ledger is canonical' GEMINI.md

for command in $commands; do
  grep -q "/ldd:$command" "skills/ldd-$command/SKILL.md"
  grep -q 'Repo-local ledger is canonical' "skills/ldd-$command/SKILL.md"
  grep -q 'External mutations require human confirmation' "skills/ldd-$command/SKILL.md"
  grep -q 'display_name: "LDD ' "skills/ldd-$command/agents/openai.yaml"
  grep -q "ldd-$command" "commands/ldd/$command.md"
  grep -q 'canonical' "commands/ldd/$command.md"
  grep -q "description =" "commands/ldd/$command.toml"
  grep -q "prompt =" "commands/ldd/$command.toml"
  grep -q "/ldd:$command" "commands/ldd/$command.toml"
  grep -q "ldd-$command" "commands/ldd/$command.toml"
  grep -q 'Agent Skill' "commands/ldd/$command.toml"
  grep -q 'canonical' "commands/ldd/$command.toml"
done

grep -q '`.ldd/config.yml`' skills/ldd-setup/SKILL.md
grep -q 'docs/tickets/_drafts/' skills/ldd-setup/SKILL.md
grep -q 'docs/tickets/_archive/' skills/ldd-setup/SKILL.md

grep -q 'Read-only' skills/ldd-next/SKILL.md
grep -q 'It never mutates GitHub or local files' skills/ldd-next/SKILL.md
grep -q 'next: /ldd:decompose' skills/ldd-next/SKILL.md
grep -q 'execution_context' skills/ldd-next/SKILL.md
grep -q 'derive equivalent state' skills/ldd-next/SKILL.md
grep -q 'next: /ldd:verify <child-ticket-id>' skills/ldd-next/SKILL.md
grep -q 'next: /ldd:close <child-ticket-id>' skills/ldd-next/SKILL.md
grep -q 'next: /ldd:close <parent-ticket-id>' skills/ldd-next/SKILL.md
grep -q 'closure.status' skills/ldd-next/SKILL.md
grep -q 'optional_cleanup_command: /ldd:archive <parent-ticket-id>' skills/ldd-next/SKILL.md
grep -q 'optional cleanup, not as `next_command`' skills/ldd-next/SKILL.md
grep -q 'next_human_action' skills/ldd-next/SKILL.md
grep -q '/ldd:approve <ticket-id>' skills/ldd-next/SKILL.md
grep -q 'does not perform mutations' skills/ldd-next/SKILL.md
grep -q 'Do not infer them from the conversation' skills/ldd-next/SKILL.md
grep -q 'implementation PR state is checked' skills/ldd-next/SKILL.md
grep -q 'Verification owns recording observed merge evidence' skills/ldd-next/SKILL.md
grep -q 'Never treat a conversational claim such as "merged" as merge evidence' skills/ldd-next/SKILL.md
grep -q 'Approval Gate Detection' skills/ldd-next/SKILL.md
grep -q 'copyable command block containing only the next command' skills/ldd-next/SKILL.md
grep -Eq 'execution_context\.phase.*refine' skills/ldd-next/SKILL.md
if grep -q 'artifacts.prd.status: draft.*approved_artifacts.prd' skills/ldd-next/SKILL.md skills/ldd-approve/SKILL.md; then
  echo "draft PRDs must not be treated as approval-ready before refinement" >&2
  exit 1
fi

grep -q 'Approve exactly one PRD, SDD, or plan gate' skills/ldd-approve/SKILL.md
grep -q 'Plan Approval Workflow' skills/ldd-approve/SKILL.md
grep -q 'Plan candidate' skills/ldd-approve/SKILL.md
grep -q 'next_command: /ldd:decompose 123' skills/ldd-approve/SKILL.md
grep -q 'exactly one approval gate is active' skills/ldd-approve/SKILL.md
grep -q 'GitHub is the first external tracker dogfooding path' skills/ldd-approve/SKILL.md
grep -q 'GitHub issue number as the stable ticket ID' skills/ldd-approve/SKILL.md
grep -q 'Do not invent or preserve an `LDD-0004` style ID in GitHub tracker mode' skills/ldd-approve/SKILL.md
grep -q 'GitHub SDD issue' skills/ldd-approve/SKILL.md
grep -q 'PRD #<prd_issue_number> SDD:' skills/ldd-approve/SKILL.md
grep -q 'child ticket of the PRD issue' skills/ldd-approve/SKILL.md

grep -q 'do not read the codebase as a design input' skills/ldd-scope/SKILL.md
grep -q 'This is a bounded shared understanding gate' skills/ldd-scope/SKILL.md
grep -q 'Existing promoted Product Requirement tickets do not block new scoping work' skills/ldd-scope/SKILL.md
grep -q 'Keep at most one active local draft' skills/ldd-scope/SKILL.md
grep -q 'create a new draft' skills/ldd-scope/SKILL.md
grep -q 'do not read the codebase as a design input' skills/ldd-elaborate/SKILL.md
grep -q 'This is a bounded shared understanding gate' skills/ldd-elaborate/SKILL.md
grep -q 'do not read the codebase as a design input' skills/ldd-refine/SKILL.md
grep -q 'This is a bounded shared understanding gate' skills/ldd-refine/SKILL.md

grep -q 'draft_directory: docs/tickets/_drafts' skills/ldd-setup/assets/templates/config.yml
grep -q 'archive_directory: docs/tickets/_archive' skills/ldd-setup/assets/templates/config.yml
grep -q 'GitHub-first managed projections' skills/ldd-setup/assets/templates/config.yml
grep -q 'Linear and Jira are follow-on collaboration surfaces' skills/ldd-setup/assets/templates/config.yml
grep -q 'schema_version: 1' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'children: \[\]' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'research:' skills/ldd-setup/assets/templates/ledger.yml
grep -q '# LDD Research' skills/ldd-setup/assets/templates/research.md
grep -q 'Readiness Decision' skills/ldd-setup/assets/templates/research.md
grep -q 'Sensitivity Handling' skills/ldd-setup/assets/templates/research.md
grep -q 'external_body_hash:' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'managed_body_version:' skills/ldd-setup/assets/templates/ledger.yml
grep -q 'current_gate: scope' skills/ldd-setup/assets/templates/ledger.yml
if grep -q 'current_gate: prd_approval' skills/ldd-setup/assets/templates/ledger.yml; then
  echo "new draft ledger template must not start at PRD approval gate" >&2
  exit 1
fi
grep -q '# PRD:' skills/ldd-setup/assets/templates/prd.md
grep -q 'Product Manager artifact' skills/ldd-setup/assets/templates/prd.md
grep -q 'PRD Handoff Checklist' skills/ldd-setup/assets/templates/prd.md
grep -q 'No implementation decisions' skills/ldd-setup/assets/templates/prd.md
grep -q 'avoid prescribing command mechanics' skills/ldd-setup/assets/templates/prd.md
grep -q 'Avoid: Gherkin/Cucumber syntax here' skills/ldd-setup/assets/templates/prd.md
grep -q 'Given/When/Then' skills/ldd-setup/assets/templates/prd.md
grep -q '# Software Design Document:' skills/ldd-setup/assets/templates/sdd.md
grep -q 'Quality bar:' skills/ldd-setup/assets/templates/sdd.md
grep -q 'ADR threshold:' skills/ldd-setup/assets/templates/sdd.md
grep -q 'Review Checklist' skills/ldd-setup/assets/templates/sdd.md
grep -q '# Implementation Plan:' skills/ldd-setup/assets/templates/plan.md
grep -q 'Acceptance Criteria Traceability' skills/ldd-setup/assets/templates/plan.md
grep -q 'Slice quality bar:' skills/ldd-setup/assets/templates/plan.md
grep -q 'Review load' skills/ldd-setup/assets/templates/plan.md
grep -q '200 changed files' skills/ldd-setup/assets/templates/plan.md
grep -q 'must not introduce new architecture decisions' skills/ldd-setup/assets/templates/plan.md
grep -q '## Problem Statement' skills/ldd-setup/assets/templates/issue-body-prd.md
grep -q 'GitHub issue projection' skills/ldd-setup/assets/templates/issue-body-prd.md
grep -q '## LDD Links' skills/ldd-setup/assets/templates/issue-body-prd.md
grep -q '## Parent Product Requirement' skills/ldd-setup/assets/templates/issue-body-sdd.md
grep -q '# PRD {prd_issue} SDD: {title}' skills/ldd-setup/assets/templates/issue-body-sdd.md
grep -q 'GitHub child issue projection for SDD visibility' skills/ldd-setup/assets/templates/issue-body-sdd.md
grep -q 'implementation child issues created by decomposition are children of this SDD issue' skills/ldd-setup/assets/templates/issue-body-sdd.md
grep -q '## What to build' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q 'native child/sub-issue projection' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q 'SDD issue:' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q 'Tracker parent relationship:' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## Acceptance criteria' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## Blocked by' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## User stories covered' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q '## Review load' skills/ldd-setup/assets/templates/issue-body-child.md
grep -q 'Decompose only from an approved plan' skills/ldd-decompose/SKILL.md
grep -q 'vertical slices' skills/ldd-decompose/SKILL.md
grep -q 'cognitive-load budget' skills/ldd-decompose/SKILL.md
grep -q '200 changed files' skills/ldd-decompose/SKILL.md
grep -q 'focused human review' skills/ldd-decompose/SKILL.md
grep -q 'Preview Before Creation' skills/ldd-decompose/SKILL.md
grep -q 'independently grabbable' skills/ldd-decompose/SKILL.md
grep -q 'SDD #<sdd_issue_number> Slice <slice-number>:' skills/ldd-decompose/SKILL.md
grep -q "LDD's standalone child issue shape" skills/ldd-decompose/SKILL.md
grep -q 'external contribution' skills/ldd-decompose/SKILL.md
grep -q 'projected as GitHub issues' skills/ldd-decompose/SKILL.md
grep -q 'native GitHub sub-issue' skills/ldd-decompose/SKILL.md
grep -q 'POST /repos/{owner}/{repo}/issues/{sdd_issue_number}/sub_issues' skills/ldd-decompose/SKILL.md
grep -q 'sub_issue_id' skills/ldd-decompose/SKILL.md
grep -q 'body-only linked issue fallback requires a separate explicit human confirmation' skills/ldd-decompose/SKILL.md
grep -q 'grandchildren of the PRD issue' skills/ldd-decompose/SKILL.md
grep -q 'Built-in TDD Loop' skills/ldd-implement/SKILL.md
grep -q 'Run this loop directly from this skill' skills/ldd-implement/SKILL.md
grep -q 'Write the smallest focused test' skills/ldd-implement/SKILL.md
grep -q 'Run the focused test and confirm it fails' skills/ldd-implement/SKILL.md
grep -q 'approved PRD, SDD, and plan boundaries' skills/ldd-implement/SKILL.md
grep -q 'closure.status: verification_required' skills/ldd-implement/SKILL.md
grep -q 'Do not archive child tickets' skills/ldd-implement/SKILL.md
grep -q 'Do not close external child work items' skills/ldd-implement/SKILL.md
grep -q 'implementation PR is a managed projection' skills/ldd-implement/SKILL.md
grep -q 'child-ticket closure' skills/ldd-verify/SKILL.md
grep -q 'not a general repository healthcheck' skills/ldd-verify/SKILL.md
grep -q 'implementation completion' skills/ldd-verify/SKILL.md
grep -q 'closure.status' skills/ldd-verify/SKILL.md
grep -q 'passed | failed | override_required' skills/ldd-verify/SKILL.md
grep -q 'approved parent PRD, approved parent SDD, approved parent plan' skills/ldd-verify/SKILL.md
grep -q 'scope/design/plan drift' skills/ldd-verify/SKILL.md
grep -q 'external ticket drift is unresolved' skills/ldd-verify/SKILL.md
grep -q 'Implementation PR State Rule' skills/ldd-verify/SKILL.md
grep -q 'implementation PR state is externally checked' skills/ldd-verify/SKILL.md
grep -q 'Never treat a conversational claim such as "merged" as merge evidence' skills/ldd-verify/SKILL.md
grep -q 'records the observed `mergedAt` and merge commit as evidence' skills/ldd-verify/SKILL.md
grep -q 'verification.md' skills/ldd-verify/SKILL.md
grep -q 'Do not mutate external trackers' skills/ldd-verify/SKILL.md
grep -q 'Apply closure for one verified child work item' skills/ldd-close/SKILL.md
grep -q 'artifacts.verification.status: passed' skills/ldd-close/SKILL.md
grep -q 'closure.status: verified' skills/ldd-close/SKILL.md
grep -q 'External mutations require human confirmation' skills/ldd-close/SKILL.md
grep -q 'does not archive local ticket files' skills/ldd-close/SKILL.md
grep -q 'Do not archive or move local ticket directories' skills/ldd-close/SKILL.md
grep -q 'Parent Roll-up Workflow' skills/ldd-close/SKILL.md
grep -q 'GitHub issue closure is the expected external close projection' skills/ldd-close/SKILL.md
grep -q 'Do not rely on GitHub auto-close keywords' skills/ldd-close/SKILL.md
grep -q 'every child is verified and closeable' skills/ldd-close/SKILL.md
grep -q 'Keep the parent directory in place' skills/ldd-close/SKILL.md
grep -q 'parent close requested while any child is not verified and closeable' skills/ldd-close/SKILL.md
grep -q 'Move already-closed local LDD ticket packages' skills/ldd-archive/SKILL.md
grep -q 'storage hygiene only' skills/ldd-archive/SKILL.md
grep -q 'No external tracker writes are allowed' skills/ldd-archive/SKILL.md
grep -q 'closure.status: closed | externally_closed | archived' skills/ldd-archive/SKILL.md
grep -q 'archive_directory' skills/ldd-archive/SKILL.md
grep -q 'child_archived' skills/ldd-archive/SKILL.md
grep -q 'parent_archived' skills/ldd-archive/SKILL.md
grep -q 'standard PM inputs' skills/ldd-research/SKILL.md
grep -q 'full read-only' skills/ldd-research/SKILL.md
grep -q 'ready_for_scope' skills/ldd-research/SKILL.md
grep -q 'blocked_on_more_input' skills/ldd-research/SKILL.md
grep -q 'split_recommended' skills/ldd-research/SKILL.md
grep -q 'not_a_product_requirement' skills/ldd-research/SKILL.md
grep -q 'financially sensitive' skills/ldd-research/SKILL.md
for command in $commands; do
  grep -q 'Input Quality Gate' "skills/ldd-$command/SKILL.md"
  grep -q 'earliest LDD command' "skills/ldd-$command/SKILL.md"
done
grep -q 'Verification status: pending | passed | failed | override_required' skills/ldd-setup/assets/templates/verification.md
grep -q 'Boundary: child-ticket closure only, not repository health' skills/ldd-setup/assets/templates/verification.md
grep -q 'External tracker drift: pending' skills/ldd-setup/assets/templates/verification.md
grep -q 'Human confirmation required before external mutation: yes' skills/ldd-setup/assets/templates/verification.md
grep -q 'Product Boundary' skills/ldd-setup/assets/templates/pr-body-prd.md
grep -q 'Handoff Checklist' skills/ldd-setup/assets/templates/pr-body-prd.md
grep -q 'Traceability Checks' skills/ldd-setup/assets/templates/pr-body-sdd-plan.md
grep -q 'GitHub-first managed projection for SDD and plan review' skills/ldd-setup/assets/templates/pr-body-sdd-plan.md
grep -q 'Does this implementation follow the approved plan?' skills/ldd-setup/assets/templates/pr-body-implementation.md
grep -q 'GitHub-first managed projection for implementation review' skills/ldd-setup/assets/templates/pr-body-implementation.md
grep -q 'Plan Conformance' skills/ldd-setup/assets/templates/pr-body-implementation.md
grep -q 'Treat <code>plan.md</code> as the source of truth' skills/ldd-setup/assets/templates/plan.html

grep -q 'artifact quality guidance' skills/ldd-setup/SKILL.md
grep -q 'GitHub-first tracker readiness' skills/ldd-setup/SKILL.md
grep -q 'PRD template as a quality contract' skills/ldd-scope/SKILL.md
grep -q 'should not prescribe exact command behavior' skills/ldd-elaborate/SKILL.md
grep -q 'Preserve the Product Manager boundary' skills/ldd-refine/SKILL.md
grep -q 'Run /ldd:approve <ticket-id> to approve this PRD' skills/ldd-refine/SKILL.md
grep -q 'GitHub issue number as the promoted ticket ID' skills/ldd-refine/SKILL.md
grep -q "SDD template's quality bar" skills/ldd-design/SKILL.md
grep -q 'SDD approval must be recorded through `/ldd:approve <ticket-id>`' skills/ldd-design/SKILL.md
grep -q "plan template's traceability" skills/ldd-plan/SKILL.md
grep -q 'Stop at explicit plan approval through `/ldd:approve <ticket-id>`' skills/ldd-plan/SKILL.md
grep -q 'next_command: /ldd:approve <ticket-id>' skills/ldd-plan/SKILL.md
grep -q 'plan exists but is not approved' skills/ldd-next/SKILL.md
grep -q 'repo-local ledger as canonical workflow state' docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md

if grep -R -n -E 'Pocock|to-issues|to-prd|/tdd|/setup-matt|Superpowers|external TDD skill required|requires? an external .*skill' skills commands README.md CONTEXT.md docs/superpowers/specs/2026-05-12-local-ledger-mvp-design.md GEMINI.md agent-skills.json; then
  echo "LDD command package must not depend on external skills" >&2
  exit 1
fi

echo "LDD MVP installable skills validated"
