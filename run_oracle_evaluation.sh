#!/usr/bin/env bash
# Copyright (C) 2026 HarnessMinimizer Authors
# SPDX-License-Identifier: MIT
# See LICENSE.MIT for the full license.

set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${HARNESSMINIMIZER_PYTHON:-}" ]]; then
    evaluation_python="$HARNESSMINIMIZER_PYTHON"
elif [[ -x "$repo_dir/.venv/bin/python" ]]; then
    evaluation_python="$repo_dir/.venv/bin/python"
elif [[ -x "$repo_dir/.venv-host/bin/python" ]]; then
    evaluation_python="$repo_dir/.venv-host/bin/python"
else
    evaluation_python=python3
fi
exec "$evaluation_python" - "$repo_dir" "$@" <<'PYTHON'
from pathlib import Path
import sys
sys.path.insert(0, str(Path(sys.argv[1]) / "src"))
from harnessminimizer.evaluation_cli import run_evaluation_batch
raise SystemExit(run_evaluation_batch("oracle", argv=sys.argv[2:]))
PYTHON
