import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const repo = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const siblingRepo = resolve(repo, "..", "gadd-cad-render-test");
const reportPath = join(repo, "gadd", "adversarial-run-report.md");

const checks = [];

function pass(name, detail = "") {
  checks.push({ name, status: "PASS", detail });
}

function fail(name, error) {
  checks.push({ name, status: "FAIL", detail: error.message });
}

function check(name, fn) {
  try {
    fn();
    pass(name);
  } catch (error) {
    fail(name, error);
  }
}

function get(data, path) {
  return path.split(".").reduce((current, part) => {
    if (current && Object.hasOwn(current, part)) return current[part];
    return undefined;
  }, data);
}

function command(name, id) {
  return `/gadd:${name} ${id}`;
}

function approvedTriaged(ledger) {
  return Boolean(
    get(ledger, "triage.approved_outcome.status") === "approved" &&
      get(ledger, "triage.approved_outcome.boundary_source") &&
      get(ledger, "triage.approved_outcome.approved_hash"),
  );
}

function implemented(ledger) {
  return get(ledger, "artifacts.implementation.status") === "completed";
}

function verified(ledger) {
  return get(ledger, "artifacts.verification.status") === "passed";
}

function closureStatus(ledger) {
  return get(ledger, "closure.status");
}

function boundaryMissing(ledger) {
  return [
    "ready_for_implementation",
    "needs_sdd",
    "needs_prd",
    "verification_required",
    "verified",
    "closed",
    "archived",
  ].includes(get(ledger, "work_item.state")) && !approvedTriaged(ledger);
}

function terminalStateInconsistent(ledger) {
  const status = closureStatus(ledger);
  if (["verified", "closed", "externally_closed", "archived"].includes(status) && !implemented(ledger)) {
    return true;
  }
  if (["verified", "closed", "externally_closed", "archived"].includes(status) && !verified(ledger)) {
    return true;
  }
  if (["closed", "archived"].includes(get(ledger, "work_item.state")) && !["closed", "externally_closed", "archived"].includes(status)) {
    return true;
  }
  return false;
}

function closeable(ledger) {
  return verified(ledger) && closureStatus(ledger) === "verified";
}

function closed(ledger) {
  return ["closed", "externally_closed", "archived"].includes(closureStatus(ledger));
}

function blocked(reason) {
  return { next_command: "blocked", next_human_action: reason };
}

function deriveChild(children) {
  const active = children.filter((child) => !closed(child));
  if (!active.length) return null;
  for (const child of active) {
    if (boundaryMissing(child)) {
      return {
        next_command: command("triage", get(child, "work_item.id")),
        next_human_action: "approve or repair the triage outcome boundary",
      };
    }
    if (terminalStateInconsistent(child)) return blocked("reconcile rogue Work Item state before continuing");
  }
  if (children.length && children.every((child) => closed(child) || closeable(child))) return null;
  for (const child of active) {
    if (closeable(child)) {
      return { next_command: command("close", get(child, "work_item.id")), next_human_action: "human-approved closure" };
    }
  }
  for (const child of active) {
    if (implemented(child) && !verified(child)) {
      return { next_command: command("verify", get(child, "work_item.id")), next_human_action: "none" };
    }
  }
  for (const child of active) {
    if (get(child, "work_item.state") === "ready_for_implementation" && approvedTriaged(child)) {
      return { next_command: command("implement", get(child, "work_item.id")), next_human_action: "none" };
    }
  }
  return null;
}

function deriveNext(parent, children = []) {
  const id = get(parent, "work_item.id");
  if (boundaryMissing(parent)) return { next_command: command("triage", id), next_human_action: "approve or repair the triage outcome boundary" };
  if (terminalStateInconsistent(parent)) return blocked("reconcile rogue Work Item state before continuing");
  if (closed(parent)) {
    const done = { next_command: "done", next_human_action: "none" };
    if (["closed", "externally_closed"].includes(closureStatus(parent))) done.optional_cleanup_command = command("archive", id);
    return done;
  }
  if (children.length && children.every((child) => closed(child) || closeable(child))) {
    return { next_command: command("close", id), next_human_action: "human-approved parent roll-up closure" };
  }
  const child = deriveChild(children);
  if (child) return child;
  if (closeable(parent)) return { next_command: command("close", id), next_human_action: "human-approved closure" };
  if (implemented(parent) && !verified(parent)) return { next_command: command("verify", id), next_human_action: "none" };
  if (get(parent, "artifacts.plan.status") === "approved" && !children.length) return { next_command: command("decompose", id), next_human_action: "none" };
  if (get(parent, "artifacts.plan.status") === "draft") return { next_command: command("approve", id), next_human_action: command("approve", id) };
  if (get(parent, "artifacts.sdd.status") === "approved") {
    if (get(parent, "work_item.type") === "engineering_change" && get(parent, "artifacts.sdd.implementation_route") === "single") {
      return { next_command: command("implement", id), next_human_action: "none" };
    }
    return { next_command: command("plan", id), next_human_action: "none" };
  }
  if (get(parent, "artifacts.sdd.status") === "draft") return { next_command: command("approve", id), next_human_action: command("approve", id) };
  if (get(parent, "artifacts.prd.status") === "approved") return { next_command: command("design", id), next_human_action: "none" };
  if (get(parent, "execution_context.phase") === "refine" && get(parent, "execution_context.current_gate") === "prd_approval") {
    return { next_command: command("approve", id), next_human_action: command("approve", id) };
  }
  if (get(parent, "execution_context.phase") === "scope") return { next_command: command("elaborate", id), next_human_action: "none" };
  if (get(parent, "execution_context.phase") === "elaborate") return { next_command: command("refine", id), next_human_action: "none" };
  const state = get(parent, "work_item.state");
  if (state === "ready_for_implementation") return { next_command: command("implement", id), next_human_action: "none" };
  if (state === "needs_sdd") return { next_command: command("design", id), next_human_action: "none" };
  if (state === "needs_prd") {
    return ["ready_for_scope", "completed"].includes(get(parent, "artifacts.research.status"))
      ? { next_command: command("scope", id), next_human_action: "none" }
      : { next_command: command("research", id), next_human_action: "none" };
  }
  if (["duplicate", "out_of_scope", "not_gadd_work"].includes(state)) return blocked(get(parent, "execution_context.next_human_action") || "terminal triage outcome");
  if (state === "blocked_on_human_decision") return blocked(get(parent, "execution_context.next_human_action") || "human decision required");
  return { next_command: command("next", id), next_human_action: "inspect ambiguous workflow state" };
}

function base(id, state = "ready_for_implementation", type = "bug_fix") {
  return {
    work_item: { id, state, type },
    triage: { approved_outcome: { status: "approved", boundary_source: "triage.md", approved_hash: `${id}-hash` } },
    artifacts: { implementation: { status: null }, verification: { status: null } },
    closure: { status: "open" },
  };
}

function withFields(ledger, fields) {
  return structuredClone({ ...ledger, ...fields });
}

const cases = [
  ["happy direct ready", base("CAD-DIRECT"), [], "/gadd:implement CAD-DIRECT"],
  ["happy direct implemented", withFields(base("CAD-DIRECT"), { artifacts: { implementation: { status: "completed" }, verification: { status: null } }, closure: { status: "verification_required" } }), [], "/gadd:verify CAD-DIRECT"],
  ["happy direct verified", withFields(base("CAD-DIRECT"), { artifacts: { implementation: { status: "completed" }, verification: { status: "passed", path: "verification.md" } }, closure: { status: "verified" } }), [], "/gadd:close CAD-DIRECT"],
  ["happy direct closed", withFields(base("CAD-DIRECT"), { work_item: { id: "CAD-DIRECT", state: "closed", type: "bug_fix" }, artifacts: { implementation: { status: "completed" }, verification: { status: "passed", path: "verification.md" } }, closure: { status: "closed" } }), [], "done"],
  ["product needs research", base("CAD-PRD", "needs_prd", "product_requirement"), [], "/gadd:research CAD-PRD"],
  ["product research ready", withFields(base("CAD-PRD", "needs_prd", "product_requirement"), { artifacts: { research: { status: "ready_for_scope" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:scope CAD-PRD"],
  ["product scoped", withFields(base("CAD-PRD", "needs_prd", "product_requirement"), { execution_context: { phase: "scope" } }), [], "/gadd:elaborate CAD-PRD"],
  ["product elaborated", withFields(base("CAD-PRD", "needs_prd", "product_requirement"), { execution_context: { phase: "elaborate" } }), [], "/gadd:refine CAD-PRD"],
  ["product refined approval", withFields(base("CAD-PRD", "needs_prd", "product_requirement"), { execution_context: { phase: "refine", current_gate: "prd_approval" } }), [], "/gadd:approve CAD-PRD"],
  ["product approved PRD", withFields(base("CAD-PRD", "needs_prd", "product_requirement"), { artifacts: { prd: { status: "approved" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:design CAD-PRD"],
  ["draft SDD approval", withFields(base("CAD-SDD", "needs_sdd", "engineering_change"), { artifacts: { sdd: { status: "draft" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:approve CAD-SDD"],
  ["approved single SDD", withFields(base("CAD-SDD", "needs_sdd", "engineering_change"), { artifacts: { sdd: { status: "approved", implementation_route: "single" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:implement CAD-SDD"],
  ["approved plan-required SDD", withFields(base("CAD-SDD", "needs_sdd", "engineering_change"), { artifacts: { sdd: { status: "approved", implementation_route: "plan_required" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:plan CAD-SDD"],
  ["draft plan approval", withFields(base("CAD-PLAN", "needs_sdd", "engineering_change"), { artifacts: { sdd: { status: "approved" }, plan: { status: "draft" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:approve CAD-PLAN"],
  ["approved plan decomposes", withFields(base("CAD-PLAN", "needs_sdd", "engineering_change"), { artifacts: { sdd: { status: "approved" }, plan: { status: "approved" }, implementation: { status: null }, verification: { status: null } } }), [], "/gadd:decompose CAD-PLAN"],
  ["child ready", withFields(base("CAD-PARENT", "needs_sdd", "engineering_change"), { artifacts: { plan: { status: "approved" }, implementation: { status: null }, verification: { status: null } } }), [base("CAD-CHILD", "ready_for_implementation", "task")], "/gadd:implement CAD-CHILD"],
  ["child implemented", withFields(base("CAD-PARENT", "needs_sdd", "engineering_change"), { artifacts: { plan: { status: "approved" }, implementation: { status: null }, verification: { status: null } } }), [withFields(base("CAD-CHILD", "verification_required", "task"), { artifacts: { implementation: { status: "completed" }, verification: { status: null } }, closure: { status: "verification_required" } })], "/gadd:verify CAD-CHILD"],
  ["child verified", withFields(base("CAD-PARENT", "needs_sdd", "engineering_change"), { artifacts: { plan: { status: "approved" }, implementation: { status: null }, verification: { status: null } } }), [withFields(base("CAD-CHILD", "verified", "task"), { artifacts: { implementation: { status: "completed" }, verification: { status: "passed", path: "verification.md" } }, closure: { status: "verified" } })], "/gadd:close CAD-PARENT"],
  ["terminal duplicate", withFields(base("CAD-DUP", "duplicate"), { execution_context: { next_human_action: "terminal triage outcome" } }), [], "blocked"],
  ["terminal out of scope", withFields(base("CAD-OOS", "out_of_scope"), { execution_context: { next_human_action: "terminal triage outcome" } }), [], "blocked"],
  ["terminal not GADD work", withFields(base("CAD-NOT", "not_gadd_work"), { execution_context: { next_human_action: "terminal triage outcome" } }), [], "blocked"],
  ["rogue implementation before boundary", withFields(base("CAD-ROGUE"), { triage: { approved_outcome: { status: null, boundary_source: null, approved_hash: null } }, artifacts: { implementation: { status: "completed" }, verification: { status: null } } }), [], "/gadd:triage CAD-ROGUE"],
  ["rogue closure without verification", withFields(base("CAD-ROGUE"), { work_item: { id: "CAD-ROGUE", state: "closed", type: "bug_fix" }, artifacts: { implementation: { status: "completed" }, verification: { status: null } }, closure: { status: "closed" } }), [], "blocked"],
  ["rogue verification without implementation", withFields(base("CAD-ROGUE"), { work_item: { id: "CAD-ROGUE", state: "verified", type: "bug_fix" }, artifacts: { implementation: { status: null }, verification: { status: "passed", path: "verification.md" } }, closure: { status: "verified" } }), [], "blocked"],
];

check("installed all GADD skills through npx", () => {
  const lock = readFileSync(join(repo, "skills-lock.json"), "utf8");
  assert.match(lock, /gadd-next/);
  for (const skill of ["gadd-setup", "gadd-triage", "gadd-next", "gadd-implement", "gadd-verify", "gadd-close", "gadd-archive"]) {
    assert.equal(existsSync(join(repo, ".agents", "skills", skill, "SKILL.md")), true, `${skill} missing`);
  }
});

check("installed skills include rogue-state hardening", () => {
  assert.match(readFileSync(join(repo, ".agents/skills/gadd-next/SKILL.md"), "utf8"), /reconcile rogue Work Item state/);
  assert.match(readFileSync(join(repo, ".agents/skills/gadd-verify/SKILL.md"), "utf8"), /Do not pass verification from rogue direct changes alone/);
});

check("setup template files exist in local GADD workspace", () => {
  for (const file of ["config.yml", "templates/work-item-ledger.yml", "templates/prd.md", "templates/sdd.md", "templates/plan.md", "templates/verification.md"]) {
    assert.equal(existsSync(join(repo, "gadd", file)), true, `${file} missing`);
  }
});

check("GitNexus is first-class and missing availability is recorded", () => {
  const config = readFileSync(join(repo, "gadd/config.yml"), "utf8");
  assert.match(config, /preferred_tool: gitnexus/);
  assert.match(config, /required_for_triage: true/);
  assert.equal(existsSync("/usr/local/bin/gitnexus") || existsSync("/opt/homebrew/bin/gitnexus"), false);
});

check("application tests pass after GADD implementation", () => {
  const output = execFileSync("npm", ["test"], { cwd: repo, encoding: "utf8" });
  assert.match(output, /pass 2/);
});

for (const [name, parent, children, expected] of cases) {
  check(`route: ${name}`, () => {
    assert.equal(deriveNext(parent, children).next_command, expected);
  });
}

check("multi-repo PRD with repo-specific SDDs is represented", () => {
  assert.match(readFileSync(join(repo, "gadd/work-items/CAD-PRD-1001/prd.md"), "utf8"), /Approved shared product boundary/);
  assert.match(readFileSync(join(repo, "gadd/work-items/CAD-PRD-1001/ledger.yml"), "utf8"), /gadd-cad-render-test/);
  assert.match(readFileSync(join(repo, "gadd/work-items/SDD-CAD-1001/sdd.md"), "utf8"), /Boundary Source: CAD-PRD-1001/);
  assert.match(readFileSync(join(siblingRepo, "gadd/work-items/SDD-RENDER-1001/sdd.md"), "utf8"), /Boundary Source: CAD-PRD-1001/);
  assert.match(readFileSync(join(siblingRepo, "gadd/work-items/SDD-RENDER-1001/ledger.yml"), "utf8"), /CAD-PRD-1001/);
});

check("repository contains no obvious GitHub token material", () => {
  const files = execFileSync("git", ["ls-files", "--others", "--cached", "--exclude-standard"], { cwd: repo, encoding: "utf8" })
    .split("\n")
    .filter(Boolean);
  const tokenPattern = new RegExp([
    "gh" + "p_",
    "github" + "_pat_",
    "GITHUB" + "_TOKEN=",
    "BEGIN " + "OPENSSH PRIVATE KEY",
    "BEGIN " + "RSA PRIVATE KEY",
  ].join("|"));
  for (const file of files) {
    const path = join(repo, file);
    if (existsSync(path)) assert.equal(tokenPattern.test(readFileSync(path, "utf8")), false, `${file} contains token-like material`);
  }
});

const failed = checks.filter((result) => result.status === "FAIL");
const lines = [
  "# GADD Adversarial Run Report",
  "",
  `Repository: ${repo}`,
  `Sibling repository: ${siblingRepo}`,
  `Total checks: ${checks.length}`,
  `Passed: ${checks.length - failed.length}`,
  `Failed: ${failed.length}`,
  "",
  "## Checks",
  "",
  ...checks.map((result) => `- ${result.status}: ${result.name}${result.detail ? ` - ${result.detail}` : ""}`),
  "",
];
writeFileSync(reportPath, lines.join("\n"));

if (failed.length) {
  console.error(lines.join("\n"));
  process.exit(1);
}

console.log(lines.join("\n"));
