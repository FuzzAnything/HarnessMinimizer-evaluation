#!/usr/bin/env bash
# Copyright (C) 2026 HarnessMinimizer Authors
# SPDX-License-Identifier: MIT
# See LICENSE.MIT for the full license.

set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${HARNESSMINIMIZER_PYTHON:-}" ]]; then
    triage_python="$HARNESSMINIMIZER_PYTHON"
elif [[ -x "$repo_dir/.venv/bin/python" ]]; then
    triage_python="$repo_dir/.venv/bin/python"
elif [[ -x "$repo_dir/.venv-host/bin/python" ]]; then
    triage_python="$repo_dir/.venv-host/bin/python"
else
    triage_python=python3
fi
exec "$triage_python" "$repo_dir/crash_triage.py" "$@"
