# GADD Level 3 Tests

Level 3 drives installed GADD skills through an agent adapter and verifies durable repo artifacts, tracker projections, approval gates, transcripts, and manifests.

Default runs are offline:

```sh
python3 scripts/run-gadd-level3.py --adapter scripted --tracker local
```

Codex execution is opt-in:

```sh
GADD_L3_CODEX_COMMAND="codex exec" \
python3 scripts/run-gadd-level3.py --adapter codex --tracker local --strict-adapter
```

Live GitHub remains opt-in and should reuse Level 2 configuration once the local tracker path passes.

Run artifacts are written to `tests/level3/.runs/<run-id>/`. Failed runs are preserved by default.
