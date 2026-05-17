#!/usr/bin/env python3
"""Run GADD Level 3 agent end-to-end scenarios."""

from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from tests.level3.harness.run_level3 import main


if __name__ == "__main__":
    raise SystemExit(main())
