from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
import re


@dataclass(frozen=True)
class ArtifactReference:
    path: str
    kind: str


@dataclass(frozen=True)
class ArtifactFinding:
    path: str
    code: str
    message: str
    severity: str = "error"


REQUIRED_MARKERS = {
    "prd": ("acceptance", "non-goal"),
    "sdd": ("boundary", "verification"),
    "plan": ("task", "verification"),
    "triage": ("source", "reproduction", "gitnexus", "route decision", "verification"),
    "verification": ("command", "result"),
    "child": ("acceptance", "verification"),
}


def _normalized(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower())


def evaluate_artifacts(repo_root: Path, references: list[ArtifactReference]) -> list[ArtifactFinding]:
    findings: list[ArtifactFinding] = []
    for reference in references:
        artifact_path = repo_root / reference.path
        if not artifact_path.is_file():
            findings.append(
                ArtifactFinding(
                    path=reference.path,
                    code="missing-artifact",
                    message="artifact path does not exist",
                )
            )
            continue

        text = artifact_path.read_text(encoding="utf-8")
        normalized = _normalized(text)
        for marker in REQUIRED_MARKERS.get(reference.kind, ()):
            if marker not in normalized:
                message = f"artifact missing {marker}"
                if marker == "acceptance":
                    message = "artifact missing acceptance criteria"
                findings.append(
                    ArtifactFinding(
                        path=reference.path,
                        code=f"missing-{marker.replace(' ', '-')}",
                        message=message,
                    )
                )
    return findings
