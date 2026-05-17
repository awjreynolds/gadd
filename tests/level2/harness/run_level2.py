from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
import json
from pathlib import Path
import argparse
import os
import sys

from tests.level2.harness.github_client import GitHubClient, RepoRef
from tests.level2.harness.gitnexus_evidence import GitNexusEvidence
from tests.level2.harness.ticket_quality import Ticket, evaluate_ticket


ROOT = Path(__file__).resolve().parents[3]
RUNS_DIR = ROOT / "tests" / "level2" / ".runs"
EXISTING_PRODUCT_ISSUES = (1, 2, 4)
EXISTING_RENDER_ISSUES = (1,)


@dataclass(frozen=True)
class Config:
    skip_live: bool
    product_repo: RepoRef | None
    product_repo_path: Path | None
    render_repo: RepoRef | None
    render_repo_path: Path | None
    token: str | None
    cleanup: str
    run_id: str

    @property
    def product_repo_owner(self) -> str | None:
        return self.product_repo.owner if self.product_repo else None

    @property
    def product_repo_name(self) -> str | None:
        return self.product_repo.repo if self.product_repo else None


def load_config(env: dict[str, str] | None = None) -> Config:
    values = dict(os.environ if env is None else env)
    cleanup = values.get("GADD_L2_CLEANUP", "never")
    if cleanup not in {"never", "success", "always"}:
        raise ValueError("GADD_L2_CLEANUP must be one of: never, success, always")

    repo_value = values.get("GADD_L2_GITHUB_REPO")
    token = values.get("GADD_L2_GITHUB_TOKEN")
    run_id = values.get("GADD_L2_RUN_ID", f"gadd-l2-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}")
    if not repo_value:
        return Config(
            skip_live=True,
            product_repo=None,
            product_repo_path=None,
            render_repo=None,
            render_repo_path=None,
            token=token,
            cleanup=cleanup,
            run_id=run_id,
        )

    render_repo = RepoRef.parse(values["GADD_L2_RENDER_REPO"]) if values.get("GADD_L2_RENDER_REPO") else None
    render_path = Path(values["GADD_L2_RENDER_REPO_PATH"]) if values.get("GADD_L2_RENDER_REPO_PATH") else None
    return Config(
        skip_live=False,
        product_repo=RepoRef.parse(repo_value),
        product_repo_path=Path(values["GADD_L2_PRODUCT_REPO_PATH"]) if values.get("GADD_L2_PRODUCT_REPO_PATH") else None,
        render_repo=render_repo,
        render_repo_path=render_path,
        token=token,
        cleanup=cleanup,
        run_id=run_id,
    )


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run live GitHub-backed GADD Level 2 quality checks.")
    parser.add_argument("--audit-existing", action="store_true", help="Inspect existing sandbox tickets without creating new artifacts.")
    parser.add_argument("--strict", action="store_true", help="Fail instead of skipping when live GitHub env is missing.")
    return parser.parse_args(argv)


def summarize_findings(findings: list[dict]) -> str:
    count = len(findings)
    if count == 0:
        return "0 quality findings"
    if count == 1:
        return "1 quality finding"
    return f"{count} quality findings"


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def manifest_path(run_id: str) -> Path:
    return RUNS_DIR / run_id / "manifest.json"


def write_manifest(run_id: str, manifest: dict) -> None:
    path = manifest_path(run_id)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def _ticket_from_issue(issue: dict, role: str, gitnexus_available: bool) -> Ticket:
    labels = [label["name"] if isinstance(label, dict) else str(label) for label in issue.get("labels", [])]
    comments = [comment.get("body", "") for comment in issue.get("comments", [])]
    return Ticket(
        role=role,
        title=issue.get("title", ""),
        body=issue.get("body") or "",
        state=issue.get("state", "open"),
        labels=labels,
        comments=comments,
        gitnexus_available=gitnexus_available,
    )


def audit_existing(config: Config, client: GitHubClient) -> list[dict]:
    if config.product_repo is None:
        return []

    findings: list[dict] = []
    role_by_product_issue = {1: "PRD", 2: "SDD", 4: "Bug"}
    for number in EXISTING_PRODUCT_ISSUES:
        issue = client.get_issue(config.product_repo, number)
        issue["comments"] = client.list_comments(config.product_repo, number)
        ticket = _ticket_from_issue(issue, role_by_product_issue[number], gitnexus_available=True)
        for finding in evaluate_ticket(ticket):
            findings.append({"target": f"{config.product_repo.full_name}#{number}", "message": finding.message})

    if config.render_repo:
        for number in EXISTING_RENDER_ISSUES:
            issue = client.get_issue(config.render_repo, number)
            issue["comments"] = client.list_comments(config.render_repo, number)
            ticket = _ticket_from_issue(issue, "SDD", gitnexus_available=False)
            for finding in evaluate_ticket(ticket):
                findings.append({"target": f"{config.render_repo.full_name}#{number}", "message": finding.message})
    return findings


def trace_block(run_id: str, artifact: str) -> str:
    return f"## GADD Trace\n\nRun: {run_id}\nArtifact: {artifact}\n"


def normal_prd_body(run_id: str) -> str:
    return (
        "## Summary\nValidate concise GitHub handoff for shared CAD layer normalization.\n\n"
        "## Boundary\nProduct rule: trim layer names, lowercase them, and use the normalized value for comparison.\n\n"
        "## Non-Goals\nNo parser, renderer rewrite, credential, or migration work.\n\n"
        "## Repository Ownership\nProduct repo owns authoring behavior. Render repo owns render lookup behavior.\n\n"
        "## Next Action\nReview the linked repo-specific SDD tickets.\n\n"
        f"{trace_block(run_id, 'gadd/work-items/CAD-PRD-1001/prd.md')}"
    )


def product_sdd_body(run_id: str) -> str:
    return (
        "## Boundary\nProduct repo owns `normalizeLayerName` behavior.\n\n"
        "## Files\n- `cad.js`\n- `cad.test.js`\n\n"
        "## Next Action\nReview implementation evidence and run `npm test`.\n\n"
        f"{trace_block(run_id, 'gadd/work-items/SDD-CAD-1001/sdd.md')}"
    )


def render_sdd_body(run_id: str) -> str:
    return (
        "## Boundary\nRender repo owns `renderLayerKey` lookup behavior.\n\n"
        "## Files\n- `render.js`\n- `render.test.js`\n\n"
        "## Next Action\nReview render-side evidence and run `npm test`.\n\n"
        f"{trace_block(run_id, 'gadd/work-items/SDD-RENDER-1001/sdd.md')}"
    )


def child_body(run_id: str) -> str:
    return (
        "## Boundary\nImplement the product repo normalization slice only.\n\n"
        "## Acceptance Criteria\nWhitespace is trimmed, names are lowercased, and tests cover both cases.\n\n"
        "## Verification\nRun `npm test` in the product repo.\n\n"
        "## Next Action\nUse a failing test first, then implement the minimal behavior.\n\n"
        f"{trace_block(run_id, 'gadd/work-items/CAD-0001-normalize-layer-name/ledger.yml')}"
    )


def bug_body(run_id: str, evidence_markdown: str) -> str:
    return (
        "## Observed Behavior\n`normalizeLayerName(\"   \")` returns an empty key.\n\n"
        "## Expected Behavior\nWhitespace-only layer names are rejected or represented explicitly before comparison.\n\n"
        "## Reproduction\nRun `node -e \"import('./cad.js').then(({normalizeLayerName}) => console.log(JSON.stringify(normalizeLayerName('   '))))\"`.\n\n"
        f"{evidence_markdown}\n"
        "## Route Decision\nready_for_implementation with GitNexus evidence.\n\n"
        "## Next Action\nImplement the behavior with a failing test first, then run `npm test`.\n\n"
        f"{trace_block(run_id, 'gadd/work-items/BUG-0001-whitespace-layer-name/triage.md')}"
    )


def drift_body(run_id: str) -> str:
    return (
        "## Summary\nExercise drift detection for managed GitHub projection fields.\n\n"
        "## Boundary\nOnly managed body, label, and comment surfaces are under test.\n\n"
        "## Next Action\nMutate this issue externally, then confirm stale managed updates are blocked.\n\n"
        f"{trace_block(run_id, 'tests/level2/.runs/' + run_id + '/manifest.json')}"
    )


def ensure_run_labels(config: Config, client: GitHubClient, labels: list[str]) -> None:
    repos = [config.product_repo]
    if config.render_repo:
        repos.append(config.render_repo)
    for repo in repos:
        if repo is None:
            continue
        for label in labels:
            client.ensure_label(repo, label)


def run_live_scenarios(config: Config, client: GitHubClient) -> dict:
    if config.product_repo is None:
        raise ValueError("product repo is required for live scenarios")

    labels = ["gadd-l2", f"gadd-l2:{config.run_id}"]
    ensure_run_labels(
        config,
        client,
        labels + ["type:product-requirement", "type:engineering-change", "type:bug", "type:task"],
    )
    evidence = GitNexusEvidence(
        symbol="normalizeLayerName",
        file_path="cad.js",
        direct_callers=["cad.test.js"],
        risk="low",
        summary="Single exported normalization function with direct test coverage.",
    )
    prd = client.create_issue(
        config.product_repo,
        f"[GADD L2 {config.run_id}] PRD: CAD shared layer normalization",
        normal_prd_body(config.run_id),
        labels + ["type:product-requirement"],
    )
    product_sdd = client.create_issue(
        config.product_repo,
        f"[GADD L2 {config.run_id}] SDD: Product repo layer normalization",
        product_sdd_body(config.run_id),
        labels + ["type:engineering-change"],
    )
    child = client.create_issue(
        config.product_repo,
        f"[GADD L2 {config.run_id}] Child: Normalize product layer names",
        child_body(config.run_id),
        labels + ["type:task"],
    )
    bug = client.create_issue(
        config.product_repo,
        f"[GADD L2 {config.run_id}] Bug: whitespace-only layer names normalize to an empty key",
        bug_body(config.run_id, evidence.to_markdown()),
        labels + ["type:bug"],
    )
    drift = client.create_issue(
        config.product_repo,
        f"[GADD L2 {config.run_id}] Child: Drift reconciliation check",
        drift_body(config.run_id),
        labels + ["type:task"],
    )

    issues = [
        {"repo": config.product_repo.full_name, "number": prd["number"], "role": "PRD", "url": prd["html_url"]},
        {"repo": config.product_repo.full_name, "number": product_sdd["number"], "role": "SDD", "url": product_sdd["html_url"]},
        {"repo": config.product_repo.full_name, "number": child["number"], "role": "Child", "url": child["html_url"]},
        {"repo": config.product_repo.full_name, "number": bug["number"], "role": "Bug", "url": bug["html_url"]},
        {"repo": config.product_repo.full_name, "number": drift["number"], "role": "Child", "url": drift["html_url"]},
    ]
    if config.render_repo:
        render_sdd = client.create_issue(
            config.render_repo,
            f"[GADD L2 {config.run_id}] SDD: Render repo layer normalization",
            render_sdd_body(config.run_id),
            labels + ["type:engineering-change"],
        )
        issues.append(
            {
                "repo": config.render_repo.full_name,
                "number": render_sdd["number"],
                "role": "SDD",
                "url": render_sdd["html_url"],
            }
        )

    manifest = {
        "run_id": config.run_id,
        "created_at": utc_now(),
        "issues": issues,
        "status": "created",
    }
    write_manifest(config.run_id, manifest)
    return manifest


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])
    try:
        config = load_config()
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 2
    if config.skip_live:
        message = "Skipping Level 2 GitHub tests: set GADD_L2_GITHUB_REPO to run live checks."
        print(message)
        return 1 if args.strict else 0

    client = GitHubClient(config.token)
    if args.audit_existing:
        findings = audit_existing(config, client)
        for finding in findings:
            print(f"{finding['target']}: {finding['message']}", file=sys.stderr)
        print(summarize_findings(findings))
        return 1 if findings else 0

    manifest = run_live_scenarios(config, client)
    print(f"GADD Level 2 GitHub scenarios created for run {config.run_id}")
    print(f"Manifest: {manifest_path(config.run_id)}")
    print(f"Issues: {len(manifest['issues'])}")
    return 0
