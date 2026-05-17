from pathlib import Path
import tempfile
import unittest

from tests.level2.harness.artifact_quality import ArtifactReference, evaluate_artifacts


class ArtifactQualityTests(unittest.TestCase):
    def test_missing_artifact_fails(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            findings = evaluate_artifacts(
                Path(temp_dir),
                [ArtifactReference(path="gadd/work-items/BUG-0001/triage.md", kind="triage")],
            )
        self.assertEqual(["artifact path does not exist"], [finding.message for finding in findings])

    def test_thin_implementation_artifact_fails(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            path = root / "gadd/work-items/CHILD-1/work-item.md"
            path.parent.mkdir(parents=True)
            path.write_text("# Slice\n\nBuild the thing.\n", encoding="utf-8")
            findings = evaluate_artifacts(root, [ArtifactReference(path=str(path.relative_to(root)), kind="child")])
        self.assertIn("artifact missing acceptance criteria", [finding.message for finding in findings])

    def test_strong_triage_artifact_passes(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            path = root / "gadd/work-items/BUG-0001/triage.md"
            path.parent.mkdir(parents=True)
            path.write_text(
                "# Triage\n\n"
                "## Source\nGitHub issue.\n\n"
                "## Reproduction\n`npm test`\n\n"
                "## GitNexus Evidence\nnormalizeLayerName has one direct caller.\n\n"
                "## Route Decision\nready_for_implementation\n\n"
                "## Verification\nRun `npm test`.\n",
                encoding="utf-8",
            )
            findings = evaluate_artifacts(root, [ArtifactReference(path=str(path.relative_to(root)), kind="triage")])
        self.assertEqual([], findings)


if __name__ == "__main__":
    unittest.main()
