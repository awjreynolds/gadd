from __future__ import annotations

from dataclasses import dataclass
import json
from pathlib import Path


@dataclass(frozen=True)
class LocalIssue:
    role: str
    title: str
    body: str
    labels: list[str]
    state: str = "open"
    number: int | None = None


class LocalTracker:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.issue_dir = root / "tracker" / "issues"

    def create_issue(self, issue: LocalIssue) -> LocalIssue:
        self.issue_dir.mkdir(parents=True, exist_ok=True)
        number = self._next_number()
        stored = LocalIssue(
            role=issue.role,
            title=issue.title,
            body=issue.body,
            labels=list(issue.labels),
            state=issue.state,
            number=number,
        )
        self._write_issue(stored)
        return stored

    def list_issues(self) -> list[LocalIssue]:
        if not self.issue_dir.is_dir():
            return []
        return [self._read_issue(path) for path in sorted(self.issue_dir.glob("*.json"), key=lambda item: int(item.stem))]

    def _next_number(self) -> int:
        existing = [int(path.stem) for path in self.issue_dir.glob("*.json") if path.stem.isdigit()]
        return max(existing, default=0) + 1

    def _write_issue(self, issue: LocalIssue) -> None:
        path = self.issue_dir / f"{issue.number}.json"
        path.write_text(
            json.dumps(
                {
                    "number": issue.number,
                    "role": issue.role,
                    "title": issue.title,
                    "body": issue.body,
                    "labels": issue.labels,
                    "state": issue.state,
                },
                indent=2,
                sort_keys=True,
            )
            + "\n",
            encoding="utf-8",
        )

    def _read_issue(self, path: Path) -> LocalIssue:
        data = json.loads(path.read_text(encoding="utf-8"))
        return LocalIssue(
            number=int(data["number"]),
            role=str(data["role"]),
            title=str(data["title"]),
            body=str(data["body"]),
            labels=[str(label) for label in data.get("labels", [])],
            state=str(data.get("state", "open")),
        )
