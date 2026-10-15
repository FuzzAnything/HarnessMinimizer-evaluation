#!/usr/bin/env python3
# Copyright (C) 2026 HarnessMinimizer Authors
# SPDX-License-Identifier: MIT
# See LICENSE.MIT for the full license.

"""Collect the replay evaluation."""
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent / "src"))
from harnessminimizer.evaluation_cli import collect_evaluation

if __name__ == "__main__":
    raise SystemExit(collect_evaluation("replay"))
