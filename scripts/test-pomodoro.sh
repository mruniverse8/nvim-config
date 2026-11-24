#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
bash -n bin/pomodoro scripts/install-pomodoro.sh scripts/test-pomodoro.sh
"${POMODORO_NVIM:-nvim}" --headless -u NONE -i NONE -l tests/pomodoro.lua
"${POMODORO_NVIM:-nvim}" --headless -u NONE -i NONE -l tests/lazy-pomodoro.lua
python3 tests/pomodoro-launcher.py
