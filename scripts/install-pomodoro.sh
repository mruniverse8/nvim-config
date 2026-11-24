#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "$0")/.." && pwd -P)
apps="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
desktop=${POMODORO_DESKTOP_DIR:-$(xdg-user-dir DESKTOP)}
[[ -d "$desktop" ]] || { echo "Desktop directory does not exist: $desktop" >&2; exit 1; }
mkdir -p "$apps"
python3 - "$root" "$apps/pomodoro-pets.desktop" "$desktop/Pomodoro pets.desktop" <<'PY'
import os, pathlib, sys
root = pathlib.Path(sys.argv[1])
exe = str(root / 'bin/pomodoro')
# Desktop Exec escaping is not shell quoting; % is a field-code introducer.
for old, new in [('\\', '\\\\'), ('"', '\\"'), ('`', '\\`'), ('$', '\\$')]:
    exe = exe.replace(old, new)
exe = exe.replace('%', '%%')
text = (root / 'desktop/pomodoro-pets.desktop.in').read_text().replace('@EXEC@', '"' + exe + '"')
marker = 'X-Pomodoro-Managed=true\n'
text += marker
for arg in sys.argv[2:]:
    p = pathlib.Path(arg)
    if p.is_symlink() or (p.exists() and marker not in p.read_text()):
        raise SystemExit('Refusing to overwrite unrelated launcher: ' + str(p))
for arg in sys.argv[2:]:
    p = pathlib.Path(arg)
    temp = p.with_suffix('.tmp')
    with temp.open('x') as f:
        f.write(text)
    temp.chmod(0o755)
    os.replace(temp, p)
    print('Installed ' + str(p))
PY
if command -v desktop-file-validate >/dev/null; then desktop-file-validate "$apps/pomodoro-pets.desktop"; fi
if command -v gio >/dev/null; then gio set "$desktop/Pomodoro pets.desktop" metadata::trusted true 2>/dev/null || true; fi
echo 'If GNOME requests it, right-click the Desktop shortcut and choose Allow Launching.'
