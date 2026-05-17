from tests.level2.harness.ticket_quality import Ticket, evaluate_ticket
import unittest


def messages(findings):
    return [finding.message for finding in findings]


class TicketQualityTests(unittest.TestCase):
    def test_closed_ticket_fails_with_unchecked_checklist(self):
        ticket = Ticket(
            role="PRD",
            title="PRD: CAD shared layer normalization",
            body=(
                "## Summary\nClear summary.\n\n"
                "## Boundary\nClear boundary.\n\n"
                "## Next Action\nReview linked SDD tickets.\n\n"
                "## GADD Trace\nRun: gadd-l2-test\nArtifact: gadd/work-items/CAD-PRD-1001/prd.md\n\n"
                "- [ ] The product boundary is clear.\n"
            ),
            state="closed",
            labels=["gadd-l2", "type:product-requirement"],
            comments=[],
        )

        self.assertIn("closed ticket has unchecked checklist items", messages(evaluate_ticket(ticket)))

    def test_bug_ticket_fails_stale_gitnexus_missing_claim_when_evidence_exists(self):
        ticket = Ticket(
            role="Bug",
            title="Bug: whitespace-only layer names normalize to an empty key",
            body=(
                "## Observed Behavior\nnormalizeLayerName returns an empty string.\n\n"
                "## Expected Behavior\nReject whitespace-only names.\n\n"
                "## GADD Trace\nRun: gadd-l2-test\nArtifact: gadd/work-items/BUG-0001/triage.md\n\n"
                "GitNexus is not available in this test environment."
            ),
            state="open",
            labels=["gadd-l2", "type:bug"],
            comments=[],
            gitnexus_available=True,
        )

        self.assertIn(
            "ticket claims GitNexus is missing while evidence is available",
            messages(evaluate_ticket(ticket)),
        )

    def test_concise_sdd_ticket_passes_with_artifact_and_next_action(self):
        ticket = Ticket(
            role="SDD",
            title="SDD: Product repo layer normalization",
            body=(
                "## Boundary\nProduct repo owns normalizeLayerName.\n\n"
                "## Files\n- cad.js\n- cad.test.js\n\n"
                "## Next Action\nReview the SDD and implementation evidence.\n\n"
                "## GADD Trace\nRun: gadd-l2-test\nArtifact: gadd/work-items/SDD-CAD-1001/sdd.md\n"
            ),
            state="open",
            labels=["gadd-l2", "type:engineering-change"],
            comments=[],
        )

        self.assertEqual([], evaluate_ticket(ticket))


if __name__ == "__main__":
    unittest.main()
