from __future__ import annotations

from dataclasses import dataclass
import re


TOKEN_PATTERNS = [
    re.compile(r"gh[pousr]_[A-Za-z0-9_]{20,}"),
    re.compile(r"(?i)(api[_-]?key|token|secret)\s*=\s*[A-Za-z0-9_./-]{16,}"),
]


@dataclass(frozen=True)
class TranscriptFinding:
    message: str


def find_secret_like_values(text: str) -> list[TranscriptFinding]:
    findings: list[TranscriptFinding] = []
    for pattern in TOKEN_PATTERNS:
        if pattern.search(text):
            findings.append(TranscriptFinding("token-like value detected"))
            break
    return findings
