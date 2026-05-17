from pathlib import Path
import tempfile
import unittest

from tests.level3.harness.local_tracker import LocalIssue, LocalTracker


class LocalTrackerTests(unittest.TestCase):
    def test_creates_issue_file_with_labels(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            tracker = LocalTracker(Path(temp_dir))
            issue = tracker.create_issue(
                LocalIssue(
                    role="Child",
                    title="Child: Normalize product layer names",
                    body="## Next Action\nImplement with a failing test first.\n",
                    labels=["gadd-l2", "type:task"],
                )
            )

            self.assertEqual(1, issue.number)
            issue_path = Path(temp_dir) / "tracker" / "issues" / "1.json"
            self.assertTrue(issue_path.is_file())
            self.assertIn("type:task", issue_path.read_text(encoding="utf-8"))

    def test_lists_created_issues(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            tracker = LocalTracker(Path(temp_dir))
            tracker.create_issue(LocalIssue(role="PRD", title="PRD: Example", body="## Next Action\nReview.\n", labels=["gadd-l2"]))

            issues = tracker.list_issues()

            self.assertEqual(["PRD: Example"], [issue.title for issue in issues])


if __name__ == "__main__":
    unittest.main()
