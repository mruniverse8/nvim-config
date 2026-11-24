import os
from pathlib import Path
import shutil
import subprocess
import tempfile

repo = Path(__file__).resolve().parents[1]
with tempfile.TemporaryDirectory(prefix='pomodoro paths ') as tmp:
    root = Path(tmp) / 'config with spaces'
    root.mkdir()
    for name in ('bin', 'scripts', 'desktop'):
        shutil.copytree(repo / name, root / name)
    capture = Path(tmp) / 'argv'
    stub = Path(tmp) / 'stub executable'
    stub.write_text('#!/usr/bin/env python3\nimport os,sys,json\nif "--version" not in sys.argv: open(os.environ["CAPTURE"],"w").write(json.dumps(sys.argv[1:]))\n')
    stub.chmod(0o755)
    env = dict(os.environ, POMODORO_NVIM=str(stub), POMODORO_KITTY=str(stub), CAPTURE=str(capture))
    p = subprocess.run([str(root / 'bin/pomodoro'), '--focus', '0.1', '--mute'], env=env, cwd='/tmp', check=True)
    import json
    argv = json.loads(capture.read_text())
    assert str(root / 'scripts/pomodoro-init.lua') in argv
    for args in (['--bad'], ['--focus'], ['--cycles', 'abc'], ['--cycles', '0'], ['--cycles', '1.5'], ['--focus', '0'], ['--focus', '1441']):
        assert subprocess.run([str(root / 'bin/pomodoro'), *args], env=env, capture_output=True).returncode == 2
    missing = dict(env, POMODORO_NVIM='/missing-nvim')
    assert subprocess.run([str(root / 'bin/pomodoro'), '--check'], env=missing, capture_output=True).returncode == 1
    desktop = Path(tmp) / 'Desktop'; desktop.mkdir()
    data = Path(tmp) / 'data'
    env.update(POMODORO_DESKTOP_DIR=str(desktop), XDG_DATA_HOME=str(data))
    subprocess.run([str(root / 'scripts/install-pomodoro.sh')], env=env, check=True)
    entry = data / 'applications/pomodoro-pets.desktop'
    subprocess.run(['desktop-file-validate', str(entry)], check=True)
    assert 'config with spaces/bin/pomodoro"' in entry.read_text()
    subprocess.run([str(root / 'scripts/install-pomodoro.sh')], env=env, check=True)
    entry.write_text('unrelated file')
    assert subprocess.run([str(root / 'scripts/install-pomodoro.sh')], env=env, capture_output=True).returncode != 0
    assert entry.read_text() == 'unrelated file'
print('PASS AC-5: paths with spaces, arbitrary cwd, option failures, missing dependency, desktop validation, safe reinstall')
