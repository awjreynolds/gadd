from pathlib import Path
import tempfile
import unittest

from tests.level3.harness.agent_adapter import AdapterRegistry, AgentExecutionRequest
from tests.level3.harness.scripted_adapter import ScriptedAgentAdapter
from tests.level3.harness.transcript import find_secret_like_values


class AgentAdapterTests(unittest.TestCase):
    def test_registry_creates_scripted_adapter(self):
        registry = AdapterRegistry()
        registry.register("scripted", ScriptedAgentAdapter)

        adapter = registry.create("scripted")

        self.assertIsInstance(adapter, ScriptedAgentAdapter)

    def test_scripted_adapter_writes_files_and_transcript(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            request = AgentExecutionRequest(
                run_id="run-1",
                scenario_id="scenario",
                step_name="step",
                sandbox_path=root,
                prompt="Create the artifact.",
                step={
                    "scripted_response": "Approval required before design.\n",
                    "scripted_files": {
                        "gadd/work-items/ITEM/prd.md": "# PRD\n\n## Approval\nApproval required.\n"
                    },
                },
                timeout_seconds=30,
                transcript_dir=root / ".runs" / "transcripts",
            )

            result = ScriptedAgentAdapter().run(request)

            self.assertEqual(0, result.exit_status)
            self.assertTrue((root / "gadd/work-items/ITEM/prd.md").is_file())
            self.assertTrue(result.transcript_path.is_file())
            self.assertIn("Approval required", result.transcript_path.read_text(encoding="utf-8"))


class TranscriptSafetyTests(unittest.TestCase):
    def test_secret_scanner_flags_token_like_values(self):
        findings = find_secret_like_values("GH_TOKEN=ghp_abcdefghijklmnopqrstuvwxyz123456")

        self.assertEqual(["token-like value detected"], [finding.message for finding in findings])

    def test_secret_scanner_allows_normal_transcript(self):
        findings = find_secret_like_values("Approval required before design continues.")

        self.assertEqual([], findings)


if __name__ == "__main__":
    unittest.main()
