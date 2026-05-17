from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class GitNexusEvidence:
    symbol: str
    file_path: str
    direct_callers: list[str]
    risk: str
    summary: str

    def to_markdown(self) -> str:
        callers = ", ".join(self.direct_callers) if self.direct_callers else "none detected"
        return (
            "## GitNexus Evidence\n\n"
            f"- Symbol: `{self.symbol}`\n"
            f"- File: `{self.file_path}`\n"
            f"- Direct callers: {callers}\n"
            f"- Risk: {self.risk}\n"
            f"- Summary: {self.summary}\n"
        )
