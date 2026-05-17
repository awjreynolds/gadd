from __future__ import annotations

from dataclasses import dataclass
import re


ROLE_WORDS = {
    "PRD": ("prd", "product requirement"),
    "SDD": ("sdd", "design"),
    "Bug": ("bug",),
    "Child": ("child", "slice"),
    "Verification": ("verification",),
}

SECRET_PATTERNS = [
    re.compile(r"ghp_[A-Za-z0-9_]{20,}"),
    re.compile(r"github_pat_[A-Za-z0-9_]{20,}"),
    re.compile(r"(?i)(token|secret|password)\s*[:=]\s*[A-Za-z0-9_./-]{12,}"),
]


@dataclass(frozen=True)
class Ticket:
    role: str
    title: str
    body: str
    state: str
    labels: list[str]
    comments: list[str]
    gitnexus_available: bool = False
    max_words: int = 450


@dataclass(frozen=True)
class Finding:
    code: str
    message: str
    severity: str = "error"


def _has_heading(body: str, heading: str) -> bool:
    return re.search(rf"(?im)^##\s+{re.escape(heading)}\s*$", body) is not None


def _has_any_heading(body: str, headings: tuple[str, ...]) -> bool:
    return any(_has_heading(body, heading) for heading in headings)


def _word_count(text: str) -> int:
    return len(re.findall(r"\b[\w'-]+\b", text))


def _contains_secret(text: str) -> bool:
    return any(pattern.search(text) for pattern in SECRET_PATTERNS)


def _unchecked_checklist(body: str) -> bool:
    return re.search(r"(?m)^-\s+\[\s\]\s+", body) is not None


def _role_in_title(ticket: Ticket) -> bool:
    role_words = ROLE_WORDS.get(ticket.role, (ticket.role.lower(),))
    title = ticket.title.lower()
    return any(word in title for word in role_words)


def _has_trace(body: str) -> bool:
    return "gadd trace" in body.lower() and "artifact:" in body.lower()


def _has_next_action(body: str) -> bool:
    return _has_any_heading(body, ("Next Action", "Reviewer Focus", "Route Decision"))


def evaluate_ticket(ticket: Ticket) -> list[Finding]:
    findings: list[Finding] = []
    combined_text = "\n".join([ticket.body, *ticket.comments])

    if not ticket.title.strip() or not _role_in_title(ticket):
        findings.append(Finding("title-role", "title lacks clear ticket role"))
    if _word_count(ticket.body) > ticket.max_words:
        findings.append(Finding("body-too-long", "issue body exceeds configured word budget"))
    if not _has_trace(ticket.body):
        findings.append(Finding("missing-trace", "missing GADD trace with artifact reference"))
    if not _has_next_action(ticket.body):
        findings.append(Finding("missing-next-action", "missing next action or reviewer focus"))
    if "gadd-l2" not in ticket.labels:
        findings.append(Finding("missing-run-label", "missing gadd-l2 label"))
    if ticket.state.lower() == "closed" and _unchecked_checklist(ticket.body):
        findings.append(Finding("unchecked-closed", "closed ticket has unchecked checklist items"))
    if ticket.gitnexus_available and re.search(
        r"(?i)gitnexus\s+is\s+not\s+(currently\s+)?available|gitnexus\s+evidence:\s+missing",
        combined_text,
    ):
        findings.append(
            Finding(
                "stale-gitnexus",
                "ticket claims GitNexus is missing while evidence is available",
            )
        )
    if _contains_secret(combined_text):
        findings.append(Finding("secret-like-material", "ticket contains token-like or credential-like material"))

    if ticket.role in {"PRD", "SDD", "Child"} and not _has_any_heading(ticket.body, ("Boundary", "Scope", "Non-Goals")):
        findings.append(Finding("missing-boundary", "missing boundary or scope section"))
    if ticket.role == "Bug" and not _has_any_heading(ticket.body, ("Observed Behavior", "Reproduction")):
        findings.append(Finding("missing-reproduction", "bug ticket missing observed behavior or reproduction"))

    return findings
