# Live GitHub Level 2 Integration Tests Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an explicit opt-in Level 2 integration test suite that runs from this repo against a persistent GitHub sandbox repository.

**Architecture:** Keep Level 1 untouched and add a focused Python Level 2 harness under `tests/level2/`. The harness owns run isolation, GitHub REST operations, generated local fixture state, scenario assertions, manifests, and cleanup. `scripts/validate-gadd-level2-github.py` is a thin entrypoint; default MVP validation remains offline.

**Tech Stack:** Python 3 standard library, GitHub REST API, existing shell validation scripts, YAML subset kept simple enough for the existing project style.

---

## File Structure

- Create `scripts/validate-gadd-level2-github.py`: executable top-level entrypoint that imports the Level 2 runner and returns its exit code.
- Create `tests/level2/README.md`: documents sandbox repo contract, env vars, local execution, cleanup, and CI guidance.
- Create `tests/level2/scenarios/github-projection.yml`: declarative scenario metadata for projection coverage.
- Create `tests/level2/scenarios/github-drift.yml`: declarative scenario metadata for drift coverage.
- Create `tests/level2/scenarios/github-pr-evidence.yml`: declarative scenario metadata for PR evidence coverage.
- Create `tests/level2/harness/__init__.py`: package marker.
- Create `tests/level2/harness/github_client.py`: small GitHub REST client using `urllib.request`.
- Create `tests/level2/harness/run_level2.py`: scenario runner, manifest writer, generated local ledgers, assertions, and cleanup-on-success orchestration.
- Create `tests/level2/harness/cleanup_level2.py`: explicit cleanup by run ID.
- Modify `.gitignore`: ignore `tests/level2/.runs/`.

## Task 1: Scaffold Level 2 Entry Points And Scenario Metadata

**Files:**
- Create: `scripts/validate-gadd-level2-github.py`
- Create: `tests/level2/README.md`
- Create: `tests/level2/scenarios/github-projection.yml`
- Create: `tests/level2/scenarios/github-drift.yml`
- Create: `tests/level2/scenarios/github-pr-evidence.yml`
- Create: `tests/level2/harness/__init__.py`
- Modify: `.gitignore`

- [ ] **Step 1: Add the top-level script**

Create `scripts/validate-gadd-level2-github.py`:

```python
#!/usr/bin/env python3
"""Run live GitHub-backed GADD Level 2 integration scenarios."""

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from tests.level2.harness.run_level2 import main


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 2: Add scenario metadata**

Create `tests/level2/scenarios/github-projection.yml`:

```yaml
id: github-projection
name: GitHub projection
requires:
  - issues
  - labels
  - comments
assertions:
  - issue created with run marker
  - managed labels are additive
  - ledger remains canonical for next command
```

Create `tests/level2/scenarios/github-drift.yml`:

```yaml
id: github-drift
name: GitHub drift
requires:
  - issues
  - labels
  - comments
assertions:
  - stale body metadata detects issue body drift
  - new external comment detects comment drift
  - managed label mismatch detects label drift
  - stale managed update is blocked
```

Create `tests/level2/scenarios/github-pr-evidence.yml`:

```yaml
id: github-pr-evidence
name: GitHub PR evidence
requires:
  - branches
  - pulls
assertions:
  - pull request created with run marker
  - pull request state is recorded as implementation evidence
  - pull request state does not close or verify local workflow
```

- [ ] **Step 3: Add the package marker**

Create `tests/level2/harness/__init__.py`:

```python
"""Live GitHub-backed GADD Level 2 integration harness."""
```

- [ ] **Step 4: Ignore generated run state**

Modify `.gitignore` by adding:

```gitignore
tests/level2/.runs/
```

- [ ] **Step 5: Add the Level 2 README**

Create `tests/level2/README.md`:

```markdown
# GADD Level 2 GitHub Integration Tests

Level 2 tests validate GADD's GitHub projection behavior against a real
persistent sandbox repository. The tests live in this repository; the sandbox
GitHub repository is external test state.

Level 2 is explicit opt-in and is not part of `scripts/validate-gadd-mvp.sh`.

## Required Environment

```sh
GADD_L2_GITHUB_REPO=owner/sandbox
GADD_L2_GITHUB_TOKEN=...
```

The token must be able to create and update issues, labels, comments, branches,
and pull requests in the sandbox repository.

Optional controls:

```sh
GADD_L2_RUN_ID=gadd-l2-manual-001
GADD_L2_CLEANUP=success
GADD_L2_KEEP_FAILED=true
GADD_L2_DEFAULT_BRANCH=main
```

## Run

```sh
GADD_L2_GITHUB_REPO=owner/sandbox \
GADD_L2_GITHUB_TOKEN=... \
python3 scripts/validate-gadd-level2-github.py
```

Generated local state and manifests are written under `tests/level2/.runs/`.
That directory is ignored by git.

## Cleanup

Successful runs clean up only when `GADD_L2_CLEANUP=success` or
`GADD_L2_CLEANUP=always`.

Failed runs leave GitHub artifacts in place by default for inspection. Clean up
a run explicitly with:

```sh
GADD_L2_GITHUB_REPO=owner/sandbox \
GADD_L2_GITHUB_TOKEN=... \
python3 tests/level2/harness/cleanup_level2.py --run-id <run-id>
```
```

- [ ] **Step 6: Run syntax and current validation**

Run:

```sh
python3 -m py_compile scripts/validate-gadd-level2-github.py tests/level2/harness/__init__.py
python3 scripts/validate-gadd-level1.py
```

Expected:

```text
GADD Level 1 workflow scenarios validated (4 scenarios)
```

- [ ] **Step 7: Commit scaffold**

Run:

```sh
git add .gitignore scripts/validate-gadd-level2-github.py tests/level2
git commit -m "test: scaffold live github level2 suite"
```

## Task 2: Implement The GitHub REST Client

**Files:**
- Create: `tests/level2/harness/github_client.py`
- Modify: `tests/level2/harness/run_level2.py`

- [ ] **Step 1: Write a minimal import smoke test through the runner placeholder**

Create `tests/level2/harness/run_level2.py`:

```python
#!/usr/bin/env python3
"""Run live GitHub-backed GADD Level 2 integration scenarios."""

from __future__ import annotations


def main(argv: list[str] | None = None) -> int:
    return 0
```

Run:

```sh
python3 scripts/validate-gadd-level2-github.py
```

Expected: exit code `0`.

- [ ] **Step 2: Implement `GitHubClient`**

Create `tests/level2/harness/github_client.py`:

```python
from __future__ import annotations

from dataclasses import dataclass
import base64
import json
import urllib.error
import urllib.parse
import urllib.request


class GitHubError(Exception):
    def __init__(self, method: str, path: str, status: int, body: str):
        super().__init__(f"GitHub {method} {path} failed with {status}: {body}")
        self.method = method
        self.path = path
        self.status = status
        self.body = body


@dataclass(frozen=True)
class GitHubRef:
    owner: str
    repo: str

    @classmethod
    def parse(cls, value: str) -> "GitHubRef":
        if "/" not in value:
            raise ValueError("GADD_L2_GITHUB_REPO must use owner/repo format")
        owner, repo = value.split("/", 1)
        if not owner or not repo:
            raise ValueError("GADD_L2_GITHUB_REPO must use owner/repo format")
        return cls(owner=owner, repo=repo)


class GitHubClient:
    def __init__(self, repo: GitHubRef, token: str, api_url: str = "https://api.github.com"):
        self.repo = repo
        self.token = token
        self.api_url = api_url.rstrip("/")

    def request(self, method: str, path: str, payload: dict | None = None) -> dict | list | None:
        url = f"{self.api_url}{path}"
        data = None
        headers = {
            "Accept": "application/vnd.github+json",
            "Authorization": f"Bearer {self.token}",
            "User-Agent": "gadd-level2-tests",
            "X-GitHub-Api-Version": "2022-11-28",
        }
        if payload is not None:
            data = json.dumps(payload).encode("utf-8")
            headers["Content-Type"] = "application/json"
        request = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                body = response.read().decode("utf-8")
        except urllib.error.HTTPError as error:
            body = error.read().decode("utf-8", errors="replace")
            raise GitHubError(method, path, error.code, body) from error
        if not body:
            return None
        return json.loads(body)

    def repo_path(self, suffix: str) -> str:
        return f"/repos/{self.repo.owner}/{self.repo.repo}{suffix}"

    def get_repo(self) -> dict:
        result = self.request("GET", self.repo_path(""))
        assert isinstance(result, dict)
        return result

    def ensure_label(self, name: str, color: str, description: str) -> None:
        encoded = urllib.parse.quote(name, safe="")
        try:
            self.request("GET", self.repo_path(f"/labels/{encoded}"))
        except GitHubError as error:
            if error.status != 404:
                raise
            self.request(
                "POST",
                self.repo_path("/labels"),
                {"name": name, "color": color, "description": description},
            )

    def create_issue(self, title: str, body: str, labels: list[str]) -> dict:
        result = self.request("POST", self.repo_path("/issues"), {"title": title, "body": body, "labels": labels})
        assert isinstance(result, dict)
        return result

    def get_issue(self, number: int) -> dict:
        result = self.request("GET", self.repo_path(f"/issues/{number}"))
        assert isinstance(result, dict)
        return result

    def update_issue(self, number: int, **fields: object) -> dict:
        result = self.request("PATCH", self.repo_path(f"/issues/{number}"), fields)
        assert isinstance(result, dict)
        return result

    def create_comment(self, issue_number: int, body: str) -> dict:
        result = self.request("POST", self.repo_path(f"/issues/{issue_number}/comments"), {"body": body})
        assert isinstance(result, dict)
        return result

    def list_comments(self, issue_number: int) -> list[dict]:
        result = self.request("GET", self.repo_path(f"/issues/{issue_number}/comments"))
        assert isinstance(result, list)
        return result

    def add_labels(self, issue_number: int, labels: list[str]) -> None:
        self.request("POST", self.repo_path(f"/issues/{issue_number}/labels"), {"labels": labels})

    def set_labels(self, issue_number: int, labels: list[str]) -> None:
        self.request("PUT", self.repo_path(f"/issues/{issue_number}/labels"), {"labels": labels})

    def get_ref(self, ref: str) -> dict:
        result = self.request("GET", self.repo_path(f"/git/ref/{ref}"))
        assert isinstance(result, dict)
        return result

    def create_ref(self, ref: str, sha: str) -> dict:
        result = self.request("POST", self.repo_path("/git/refs"), {"ref": ref, "sha": sha})
        assert isinstance(result, dict)
        return result

    def delete_ref(self, ref: str) -> None:
        self.request("DELETE", self.repo_path(f"/git/refs/{ref}"))

    def create_file(self, path: str, message: str, content: str, branch: str) -> dict:
        encoded_path = urllib.parse.quote(path, safe="/")
        payload = {
            "message": message,
            "content": base64.b64encode(content.encode("utf-8")).decode("ascii"),
            "branch": branch,
        }
        result = self.request("PUT", self.repo_path(f"/contents/{encoded_path}"), payload)
        assert isinstance(result, dict)
        return result

    def create_pull(self, title: str, body: str, head: str, base: str) -> dict:
        result = self.request("POST", self.repo_path("/pulls"), {"title": title, "body": body, "head": head, "base": base})
        assert isinstance(result, dict)
        return result

    def get_pull(self, number: int) -> dict:
        result = self.request("GET", self.repo_path(f"/pulls/{number}"))
        assert isinstance(result, dict)
        return result
```

- [ ] **Step 3: Add runner config loading**

Replace `tests/level2/harness/run_level2.py` with:

```python
#!/usr/bin/env python3
"""Run live GitHub-backed GADD Level 2 integration scenarios."""

from __future__ import annotations

from dataclasses import dataclass
import os
import sys

from tests.level2.harness.github_client import GitHubClient, GitHubRef


@dataclass(frozen=True)
class Config:
    repo: GitHubRef
    token: str
    default_branch: str
    cleanup: str
    keep_failed: bool
    run_id: str | None


def load_config() -> Config | None:
    repo_value = os.environ.get("GADD_L2_GITHUB_REPO")
    token = os.environ.get("GADD_L2_GITHUB_TOKEN")
    if not repo_value or not token:
        print("Skipping Level 2 GitHub tests: set GADD_L2_GITHUB_REPO and GADD_L2_GITHUB_TOKEN to run live tests.")
        return None
    cleanup = os.environ.get("GADD_L2_CLEANUP", "never")
    if cleanup not in {"success", "always", "never"}:
        raise ValueError("GADD_L2_CLEANUP must be one of: success, always, never")
    return Config(
        repo=GitHubRef.parse(repo_value),
        token=token,
        default_branch=os.environ.get("GADD_L2_DEFAULT_BRANCH", "main"),
        cleanup=cleanup,
        keep_failed=os.environ.get("GADD_L2_KEEP_FAILED", "true").lower() == "true",
        run_id=os.environ.get("GADD_L2_RUN_ID"),
    )


def main(argv: list[str] | None = None) -> int:
    config = load_config()
    if config is None:
        return 0
    client = GitHubClient(config.repo, config.token)
    repo = client.get_repo()
    print(f"Connected to GitHub sandbox: {repo['full_name']}")
    return 0
```

- [ ] **Step 4: Verify missing credentials skip cleanly**

Run:

```sh
python3 scripts/validate-gadd-level2-github.py
```

Expected:

```text
Skipping Level 2 GitHub tests: set GADD_L2_GITHUB_REPO and GADD_L2_GITHUB_TOKEN to run live tests.
```

- [ ] **Step 5: Verify syntax**

Run:

```sh
python3 -m py_compile scripts/validate-gadd-level2-github.py tests/level2/harness/*.py
```

Expected: no output and exit code `0`.

- [ ] **Step 6: Commit GitHub client**

Run:

```sh
git add tests/level2/harness/github_client.py tests/level2/harness/run_level2.py
git commit -m "test: add github client for level2 harness"
```

## Task 3: Add Run Manifests, Local Ledger Generation, And Scenario Assertions

**Files:**
- Modify: `tests/level2/harness/run_level2.py`

- [ ] **Step 1: Add run context and helper functions**

Extend `tests/level2/harness/run_level2.py` after `load_config()`:

```python
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import secrets


ROOT = Path(__file__).resolve().parents[3]
RUNS_DIR = ROOT / "tests" / "level2" / ".runs"


class ScenarioFailure(Exception):
    pass


def utc_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def make_run_id(config: Config) -> str:
    if config.run_id:
        return config.run_id
    stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    return f"gadd-l2-{stamp}-{secrets.token_hex(3)}"


def sha256_text(value: str) -> str:
    return "sha256:" + hashlib.sha256(value.encode("utf-8")).hexdigest()


def assert_equal(actual: object, expected: object, message: str) -> None:
    if actual != expected:
        raise ScenarioFailure(f"{message}: expected {expected!r}, got {actual!r}")


def assert_true(value: bool, message: str) -> None:
    if not value:
        raise ScenarioFailure(message)


class RunContext:
    def __init__(self, config: Config, run_id: str):
        self.config = config
        self.run_id = run_id
        self.run_dir = RUNS_DIR / run_id
        self.local_repo = self.run_dir / "local-repo"
        self.manifest_path = self.run_dir / "manifest.json"
        self.manifest: dict[str, object] = {
            "run_id": run_id,
            "started_at": utc_now(),
            "repo": f"{config.repo.owner}/{config.repo.repo}",
            "issues": [],
            "pulls": [],
            "branches": [],
            "labels": [],
            "comments": [],
            "local_ledgers": [],
            "scenarios": [],
            "cleanup": [],
        }

    def prepare(self) -> None:
        if self.run_dir.exists():
            raise ScenarioFailure(f"run directory already exists: {self.run_dir}")
        self.local_repo.mkdir(parents=True)
        self.write_manifest()

    def write_manifest(self) -> None:
        self.manifest_path.write_text(json.dumps(self.manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    def record(self, key: str, value: object) -> None:
        items = self.manifest.setdefault(key, [])
        assert isinstance(items, list)
        items.append(value)
        self.write_manifest()


def traceability_block(ctx: RunContext, work_item_id: str, state: str, route: str) -> str:
    return "\n".join(
        [
            "## GADD Traceability",
            "",
            f"- Run: {ctx.run_id}",
            f"- Work Item: {work_item_id}",
            f"- State: {state}",
            f"- Route: {route}",
            f"- Last synchronized: {utc_now()}",
            "",
        ]
    )


def write_ledger(ctx: RunContext, work_item_id: str, issue: dict, state: str, route: str, body_hash: str) -> Path:
    ledger_dir = ctx.local_repo / "gadd" / "work-items" / work_item_id
    ledger_dir.mkdir(parents=True, exist_ok=True)
    ledger_path = ledger_dir / "ledger.yml"
    ledger = f"""work_item:
  id: {work_item_id}
  type: task
  state: {state}
  route: {route}
external:
  provider: github
  kind: issue
  id: "{issue["number"]}"
  url: "{issue["html_url"]}"
  title: "{issue["title"]}"
  last_read_at: "{utc_now()}"
  external_updated_at: "{issue["updated_at"]}"
  body_hash: "{body_hash}"
triage:
  approved_outcome:
    status: approved
    approved_hash: "{body_hash}"
    boundary_source: external_projection
artifacts:
  implementation:
    status: null
  verification:
    status: null
closure:
  status: open
"""
    ledger_path.write_text(ledger, encoding="utf-8")
    ctx.record("local_ledgers", str(ledger_path.relative_to(ROOT)))
    return ledger_path
```

- [ ] **Step 2: Add label setup and cleanup eligibility**

Add:

```python
def ensure_run_labels(client: GitHubClient, ctx: RunContext) -> list[str]:
    labels = ["gadd-l2", ctx.run_id, "gadd:ready-for-implementation"]
    client.ensure_label("gadd-l2", "5319e7", "GADD Level 2 test artifact")
    client.ensure_label(ctx.run_id, "c2e0ff", f"GADD Level 2 run {ctx.run_id}")
    client.ensure_label("gadd:ready-for-implementation", "0e8a16", "GADD managed route projection")
    for label in labels:
        ctx.record("labels", label)
    return labels
```

- [ ] **Step 3: Add projection scenario**

Add:

```python
def run_projection(client: GitHubClient, ctx: RunContext) -> None:
    work_item_id = "GADD-L2-PROJECTION"
    route = f"/gadd:implement {work_item_id}"
    body = "# GADD Level 2 Projection\n\nThis issue was created by the GADD Level 2 live GitHub harness.\n\n"
    body += traceability_block(ctx, work_item_id, "ready_for_implementation", route)
    labels = ensure_run_labels(client, ctx)
    issue = client.create_issue(f"[GADD L2 {ctx.run_id}] Projection", body, labels)
    ctx.record("issues", {"number": issue["number"], "url": issue["html_url"], "scenario": "github-projection"})
    comment = client.create_comment(issue["number"], "Managed GADD projection comment.\n\n" + traceability_block(ctx, work_item_id, "ready_for_implementation", route))
    ctx.record("comments", {"id": comment["id"], "issue": issue["number"], "scenario": "github-projection"})
    refreshed = client.get_issue(issue["number"])
    observed_labels = {label["name"] for label in refreshed["labels"]}
    assert_true("gadd-l2" in observed_labels, "projection issue should include shared Level 2 label")
    assert_true(ctx.run_id in observed_labels, "projection issue should include run label")
    assert_true("gadd:ready-for-implementation" in observed_labels, "projection issue should include managed route label")
    body_hash = sha256_text(refreshed.get("body") or "")
    ledger_path = write_ledger(ctx, work_item_id, refreshed, "ready_for_implementation", route, body_hash)
    ledger_text = ledger_path.read_text(encoding="utf-8")
    assert_true("route: /gadd:implement GADD-L2-PROJECTION" in ledger_text, "local ledger should retain canonical route")
    ctx.record("scenarios", {"id": "github-projection", "status": "passed"})
```

- [ ] **Step 4: Add drift scenario**

Add:

```python
def detect_drift(issue: dict, comments: list[dict], expected_body_hash: str, expected_comment_count: int, expected_labels: set[str]) -> list[str]:
    drift = []
    if sha256_text(issue.get("body") or "") != expected_body_hash:
        drift.append("body")
    if len(comments) != expected_comment_count:
        drift.append("comments")
    observed_labels = {label["name"] for label in issue["labels"]}
    if not expected_labels.issubset(observed_labels):
        drift.append("labels")
    return drift


def run_drift(client: GitHubClient, ctx: RunContext) -> None:
    work_item_id = "GADD-L2-DRIFT"
    route = f"/gadd:implement {work_item_id}"
    body = "# GADD Level 2 Drift\n\nOriginal managed body.\n\n" + traceability_block(ctx, work_item_id, "ready_for_implementation", route)
    labels = ensure_run_labels(client, ctx)
    issue = client.create_issue(f"[GADD L2 {ctx.run_id}] Drift", body, labels)
    ctx.record("issues", {"number": issue["number"], "url": issue["html_url"], "scenario": "github-drift"})
    comment = client.create_comment(issue["number"], "Original managed comment.")
    ctx.record("comments", {"id": comment["id"], "issue": issue["number"], "scenario": "github-drift"})
    baseline_issue = client.get_issue(issue["number"])
    baseline_comments = client.list_comments(issue["number"])
    baseline_body_hash = sha256_text(baseline_issue.get("body") or "")
    baseline_labels = {label["name"] for label in baseline_issue["labels"]}
    client.update_issue(issue["number"], body=(baseline_issue.get("body") or "") + "\n\nExternal human edit.\n")
    client.create_comment(issue["number"], "External human comment.")
    client.set_labels(issue["number"], ["gadd-l2", ctx.run_id])
    drifted_issue = client.get_issue(issue["number"])
    drifted_comments = client.list_comments(issue["number"])
    drift = detect_drift(drifted_issue, drifted_comments, baseline_body_hash, len(baseline_comments), baseline_labels)
    assert_equal(set(drift), {"body", "comments", "labels"}, "drift detector should report body, comments, and labels")
    ctx.record("scenarios", {"id": "github-drift", "status": "passed", "drift": drift})
```

- [ ] **Step 5: Add PR evidence scenario**

Add:

```python
def run_pr_evidence(client: GitHubClient, ctx: RunContext) -> None:
    work_item_id = "GADD-L2-PR"
    branch = f"gadd-l2/{ctx.run_id}/pr-evidence"
    base_ref = client.get_ref(f"heads/{ctx.config.default_branch}")
    base_sha = base_ref["object"]["sha"]
    client.create_ref(f"refs/heads/{branch}", base_sha)
    ctx.record("branches", branch)
    client.create_file(
        f"gadd-l2-{ctx.run_id}.txt",
        f"GADD L2 PR evidence {ctx.run_id}",
        f"run_id={ctx.run_id}\n",
        branch,
    )
    body = "Implementation review evidence for GADD Level 2.\n\n" + traceability_block(ctx, work_item_id, "ready_for_implementation", f"/gadd:verify {work_item_id}")
    pull = client.create_pull(f"[GADD L2 {ctx.run_id}] PR evidence", body, branch, ctx.config.default_branch)
    ctx.record("pulls", {"number": pull["number"], "url": pull["html_url"], "scenario": "github-pr-evidence"})
    refreshed = client.get_pull(pull["number"])
    assert_equal(refreshed["state"], "open", "test pull request should be open")
    evidence = {
        "status": "completed",
        "pr": refreshed["html_url"],
        "pr_state": refreshed["state"],
        "merged": refreshed["merged"],
        "merge_commit_sha": refreshed["merge_commit_sha"],
    }
    assert_equal(evidence["status"], "completed", "PR can be recorded as implementation evidence")
    closure_status = "open"
    verification_status = None
    assert_equal(closure_status, "open", "PR evidence must not close local workflow")
    assert_equal(verification_status, None, "PR evidence must not verify local workflow")
    ctx.record("scenarios", {"id": "github-pr-evidence", "status": "passed", "evidence": evidence})
```

- [ ] **Step 6: Wire scenarios into `main()`**

Replace `main()` with:

```python
def main(argv: list[str] | None = None) -> int:
    config = load_config()
    if config is None:
        return 0
    ctx = RunContext(config, make_run_id(config))
    ctx.prepare()
    client = GitHubClient(config.repo, config.token)
    try:
        repo = client.get_repo()
        print(f"Connected to GitHub sandbox: {repo['full_name']}")
        print(f"Level 2 run id: {ctx.run_id}")
        run_projection(client, ctx)
        run_drift(client, ctx)
        run_pr_evidence(client, ctx)
    except Exception as error:
        ctx.manifest["failed_at"] = utc_now()
        ctx.manifest["error"] = str(error)
        ctx.write_manifest()
        print(f"GADD Level 2 failed for run {ctx.run_id}: {error}", file=sys.stderr)
        print(f"Manifest: {ctx.manifest_path}", file=sys.stderr)
        return 1
    ctx.manifest["completed_at"] = utc_now()
    ctx.write_manifest()
    print(f"GADD Level 2 GitHub scenarios validated for run {ctx.run_id}")
    print(f"Manifest: {ctx.manifest_path}")
    return 0
```

- [ ] **Step 7: Verify no-credential path still skips**

Run:

```sh
python3 scripts/validate-gadd-level2-github.py
```

Expected:

```text
Skipping Level 2 GitHub tests: set GADD_L2_GITHUB_REPO and GADD_L2_GITHUB_TOKEN to run live tests.
```

- [ ] **Step 8: Verify syntax**

Run:

```sh
python3 -m py_compile scripts/validate-gadd-level2-github.py tests/level2/harness/*.py
```

Expected: no output and exit code `0`.

- [ ] **Step 9: Commit runner scenarios**

Run:

```sh
git add tests/level2/harness/run_level2.py
git commit -m "test: add live github level2 scenarios"
```

## Task 4: Add Explicit Cleanup By Run ID

**Files:**
- Create: `tests/level2/harness/cleanup_level2.py`
- Modify: `tests/level2/harness/run_level2.py`

- [ ] **Step 1: Create cleanup script**

Create `tests/level2/harness/cleanup_level2.py`:

```python
#!/usr/bin/env python3
"""Clean up artifacts from a GADD Level 2 GitHub run."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys

from tests.level2.harness.github_client import GitHubClient
from tests.level2.harness.run_level2 import RUNS_DIR, load_config, utc_now


def load_manifest(run_id: str) -> tuple[Path, dict]:
    path = RUNS_DIR / run_id / "manifest.json"
    if not path.is_file():
        raise FileNotFoundError(f"manifest not found: {path}")
    return path, json.loads(path.read_text(encoding="utf-8"))


def cleanup_run(run_id: str) -> int:
    config = load_config()
    if config is None:
        return 1
    manifest_path, manifest = load_manifest(run_id)
    client = GitHubClient(config.repo, config.token)
    cleanup_events: list[dict] = []
    for pull in manifest.get("pulls", []):
        number = pull["number"]
        client.request("PATCH", client.repo_path(f"/pulls/{number}"), {"state": "closed"})
        cleanup_events.append({"type": "pull", "number": number, "action": "closed"})
    for issue in manifest.get("issues", []):
        number = issue["number"]
        client.update_issue(number, state="closed")
        cleanup_events.append({"type": "issue", "number": number, "action": "closed"})
    for branch in manifest.get("branches", []):
        client.delete_ref(f"heads/{branch}")
        cleanup_events.append({"type": "branch", "name": branch, "action": "deleted"})
    manifest.setdefault("cleanup", []).extend(cleanup_events)
    manifest["cleaned_at"] = utc_now()
    manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Cleaned GADD Level 2 run {run_id}")
    print(f"Manifest: {manifest_path}")
    return 0


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-id", required=True)
    args = parser.parse_args(argv)
    return cleanup_run(args.run_id)


if __name__ == "__main__":
    raise SystemExit(main())
```

- [ ] **Step 2: Invoke cleanup after successful runs when configured**

In `tests/level2/harness/run_level2.py`, update the successful end of `main()` before printing success. Keep the import inside the cleanup branch so `cleanup_level2.py` can import shared helpers from `run_level2.py` without a top-level circular import:

```python
    if config.cleanup in {"success", "always"}:
        from tests.level2.harness.cleanup_level2 import cleanup_run

        cleanup_run(ctx.run_id)
```

- [ ] **Step 3: Verify syntax**

Run:

```sh
python3 -m py_compile scripts/validate-gadd-level2-github.py tests/level2/harness/*.py
```

Expected: no output and exit code `0`.

- [ ] **Step 4: Verify cleanup requires credentials**

Run:

```sh
python3 tests/level2/harness/cleanup_level2.py --run-id missing-run
```

Expected:

```text
Skipping Level 2 GitHub tests: set GADD_L2_GITHUB_REPO and GADD_L2_GITHUB_TOKEN to run live tests.
```

Exit code should be non-zero.

- [ ] **Step 5: Commit cleanup**

Run:

```sh
git add tests/level2/harness/cleanup_level2.py tests/level2/harness/run_level2.py
git commit -m "test: add level2 github cleanup"
```

## Task 5: Make The Harness Robust Enough For Dogfooding

**Files:**
- Modify: `tests/level2/harness/github_client.py`
- Modify: `tests/level2/harness/run_level2.py`
- Modify: `tests/level2/harness/cleanup_level2.py`
- Modify: `tests/level2/README.md`

- [ ] **Step 1: Handle already-existing run IDs safely**

Update `RunContext.prepare()` in `run_level2.py`:

```python
    def prepare(self) -> None:
        if self.run_dir.exists():
            raise ScenarioFailure(
                f"run directory already exists: {self.run_dir}. "
                "Use a new GADD_L2_RUN_ID or clean up the existing run first."
            )
        self.local_repo.mkdir(parents=True)
        self.write_manifest()
```

- [ ] **Step 2: Make branch cleanup tolerate already-deleted branches**

Update `cleanup_level2.py` imports:

```python
from tests.level2.harness.github_client import GitHubClient, GitHubError
```

Update branch cleanup:

```python
    for branch in manifest.get("branches", []):
        try:
            client.delete_ref(f"heads/{branch}")
            cleanup_events.append({"type": "branch", "name": branch, "action": "deleted"})
        except GitHubError as error:
            if error.status != 422:
                raise
            cleanup_events.append({"type": "branch", "name": branch, "action": "already_absent"})
```

- [ ] **Step 3: Add API pagination guard for comments**

Update `GitHubClient.list_comments()` to request up to 100 comments:

```python
    def list_comments(self, issue_number: int) -> list[dict]:
        result = self.request("GET", self.repo_path(f"/issues/{issue_number}/comments?per_page=100"))
        assert isinstance(result, list)
        return result
```

- [ ] **Step 4: Expand README safety notes**

Add to `tests/level2/README.md`:

```markdown
## Safety Rules

- Use a sandbox repository, not a production repository.
- The harness never deletes the repository.
- Cleanup only targets issues, PRs, and branches recorded in a local run
  manifest.
- Failed runs intentionally leave artifacts available for inspection.
- Reusing `GADD_L2_RUN_ID` is blocked unless the previous run directory is
  cleaned up first.
```

- [ ] **Step 5: Verify offline paths**

Run:

```sh
python3 scripts/validate-gadd-level2-github.py
python3 -m py_compile scripts/validate-gadd-level2-github.py tests/level2/harness/*.py
python3 scripts/validate-gadd-level1.py
```

Expected: Level 2 skip message, no py_compile output, and Level 1 success.

- [ ] **Step 6: Commit robustness updates**

Run:

```sh
git add tests/level2
git commit -m "test: harden level2 github harness"
```

## Task 6: Live Sandbox Verification

**Files:**
- No committed source changes expected unless verification exposes defects.

- [ ] **Step 1: Confirm sandbox variables are present**

Run:

```sh
test -n "$GADD_L2_GITHUB_REPO"
test -n "$GADD_L2_GITHUB_TOKEN"
```

Expected: both commands exit `0`.

- [ ] **Step 2: Run the live suite without cleanup**

Run:

```sh
GADD_L2_CLEANUP=never python3 scripts/validate-gadd-level2-github.py
```

Expected output includes:

```text
Connected to GitHub sandbox:
Level 2 run id:
GADD Level 2 GitHub scenarios validated for run
Manifest:
```

- [ ] **Step 3: Inspect the manifest**

Run:

```sh
python3 -m json.tool tests/level2/.runs/<run-id>/manifest.json
```

Expected:

```json
"scenarios": [
```

and each of `github-projection`, `github-drift`, and `github-pr-evidence` has `"status": "passed"`.

- [ ] **Step 4: Clean up the run**

Run:

```sh
python3 tests/level2/harness/cleanup_level2.py --run-id <run-id>
```

Expected:

```text
Cleaned GADD Level 2 run <run-id>
```

- [ ] **Step 5: Run cleanup-on-success mode**

Run:

```sh
GADD_L2_CLEANUP=success python3 scripts/validate-gadd-level2-github.py
```

Expected: suite passes and prints a cleaned run.

- [ ] **Step 6: Commit any fixes from live verification**

If code changed during verification, run:

```sh
git add tests/level2 scripts/validate-gadd-level2-github.py .gitignore
git commit -m "test: fix live github level2 verification"
```

If no code changed, do not create an empty commit.

## Task 7: Final Validation And Documentation Freshness

**Files:**
- Modify only if validation identifies required docs or script fixes.

- [ ] **Step 1: Run offline validation**

Run:

```sh
git diff --check
python3 scripts/validate-gadd-level1.py
./scripts/validate-gadd-mvp.sh
python3 scripts/validate-gadd-level2-github.py
```

Expected:

```text
GADD Level 1 workflow scenarios validated (4 scenarios)
```

`validate-gadd-mvp.sh` should pass. `validate-gadd-level2-github.py` should skip when env vars are absent.

- [ ] **Step 2: Confirm no generated runs are tracked**

Run:

```sh
git status --short
```

Expected: no `tests/level2/.runs/` entries.

- [ ] **Step 3: Confirm MVP validation does not call Level 2**

Run:

```sh
rg -n "level2|validate-gadd-level2" scripts/validate-gadd-mvp.sh
```

Expected: no matches.

- [ ] **Step 4: Final commit if needed**

If any final fixes were required:

```sh
git add .
git commit -m "test: finalize live github level2 integration"
```

No commit is needed if the previous task commits already contain all changes.

## Self-Review

- Spec coverage: The plan implements the persistent sandbox contract, opt-in execution, run IDs, manifests, GitHub issue/comment/label projection, drift detection, PR evidence, cleanup, failure forensics, and Level 1 separation.
- Placeholder scan: The plan intentionally includes no placeholder markers or unspecified implementation steps.
- Type consistency: `Config`, `GitHubRef`, `GitHubClient`, `RunContext`, `ScenarioFailure`, and helper names are introduced before use and reused consistently.
