from __future__ import annotations

from dataclasses import dataclass
import json
import os
import subprocess


class GitHubError(Exception):
    pass


@dataclass(frozen=True)
class RepoRef:
    owner: str
    repo: str

    @classmethod
    def parse(cls, value: str) -> "RepoRef":
        parts = value.split("/", 1)
        if len(parts) != 2 or not parts[0] or not parts[1]:
            raise ValueError("repository must use owner/repo format")
        return cls(owner=parts[0], repo=parts[1])

    @property
    def full_name(self) -> str:
        return f"{self.owner}/{self.repo}"


class GitHubClient:
    def __init__(self, token: str | None = None):
        self.token = token

    def api(self, method: str, path: str, *fields: str) -> dict | list | None:
        command = ["gh", "api", "-X", method, path]
        for field in fields:
            command.extend(["-f", field])
        env = dict(os.environ)
        if self.token:
            env["GH_TOKEN"] = self.token
        result = subprocess.run(command, text=True, capture_output=True, env=env, check=False)
        if result.returncode != 0:
            raise GitHubError(result.stderr.strip() or result.stdout.strip())
        text = result.stdout.strip()
        if not text:
            return None
        return json.loads(text)

    def get_issue(self, repo: RepoRef, number: int) -> dict:
        value = self.api("GET", f"repos/{repo.full_name}/issues/{number}")
        if not isinstance(value, dict):
            raise GitHubError(f"unexpected issue response for {repo.full_name}#{number}")
        return value

    def create_issue(self, repo: RepoRef, title: str, body: str, labels: list[str]) -> dict:
        fields = [f"title={title}", f"body={body}"]
        for label in labels:
            fields.append(f"labels[]={label}")
        value = self.api("POST", f"repos/{repo.full_name}/issues", *fields)
        if not isinstance(value, dict):
            raise GitHubError(f"unexpected create issue response for {repo.full_name}")
        return value

    def close_issue(self, repo: RepoRef, number: int, reason: str = "completed") -> dict:
        value = self.api(
            "PATCH",
            f"repos/{repo.full_name}/issues/{number}",
            "state=closed",
            f"state_reason={reason}",
        )
        if not isinstance(value, dict):
            raise GitHubError(f"unexpected close issue response for {repo.full_name}#{number}")
        return value

    def add_comment(self, repo: RepoRef, number: int, body: str) -> dict:
        value = self.api("POST", f"repos/{repo.full_name}/issues/{number}/comments", f"body={body}")
        if not isinstance(value, dict):
            raise GitHubError(f"unexpected comment response for {repo.full_name}#{number}")
        return value

    def list_comments(self, repo: RepoRef, number: int) -> list[dict]:
        value = self.api("GET", f"repos/{repo.full_name}/issues/{number}/comments?per_page=100")
        return value if isinstance(value, list) else []
