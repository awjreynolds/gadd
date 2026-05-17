from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import argparse
import os
import sys

from tests.level2.harness.github_client import GitHubClient, RepoRef
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
    run_id = values.get("GADD_L2_RUN_ID", "gadd-l2-local")
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

    print(f"Level 2 GitHub config loaded for {config.product_repo.full_name}; run_id={config.run_id}")
    return 0
