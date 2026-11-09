# Changes

## NVIM-1 — Wider previews (2026-10-21)

Raised the document preview limit from 120 to 160 columns in both the Snacks
option and its gutter-aware sizing callback. Updated README sizing guidance.
The 40-row limit and 2x rendering density remain unchanged. Wider previews still
fit the available text area; the proportional increase is up to one third.

StyLua, Lua syntax, and `git diff --check` passed. Applied the width option and
callback to the identified running Markdown session, preserving source text and
its modified flag. That session had no visible diagrams at verification time,
so wider placements were not visually retested. Earlier narrow-window tests
remain relevant to the unchanged clamping logic.

Commit message: `fix(nvim): widen inline diagram previews (NVIM-1)`.
The user authorized this focused local commit; push remains a manual user action.
Git records the final commit hash.

## NVIM-1 — Inline Mermaid (implemented and verified, 2026-10-21)

Snacks renders the existing Mermaid fences with visible source, up to 120 columns
by 40 rows. Rendering uses twice the terminal pixel density for sharper labels.
The placement callback reserves number/sign columns and indentation; automatic
resizing prevents the right-edge clipping observed during verification.
Conversion errors are visible. Existing math concealment is retained.

Changed `lua/plugins/snacks.lua`, the image.nvim zoom callback in
`lua/config/keymaps.lua`, and README dependencies/examples. Added root tracking
and constitution records. The zoom callback keeps Markdown integration disabled
so Snacks remains the document image renderer. No plugin upgrades were made.

Installed outside Git in the existing `/home/biorn/.local/node` npm prefix:
Mermaid CLI 12.0.0, Mermaid 12.2.0, Puppeteer 25.15.0, and Puppeteer's downloaded
Chrome/Chrome Headless Shell 155.0.8059.84. Browser rendering worked with its
normal sandbox settings. Generated images remain in Neovim's Snacks cache.

Verification:

- All repository Lua modules compiled; StyLua checks on both changed Lua files
  and `git diff --check` passed.
- Mermaid CLI rendered both README examples successfully. Default CLI outputs
  were 784×103 and 784×175 PNGs.
- Real Kitty 0.49.2 / Neovim 0.13.0-dev session loaded the full LazyVim config.
  Both source blocks and inline diagrams were visually inspected with Markview.
  Doubling density increased actual cached images from 882×116 / 882×197 to
  1764×232 / 1764×394, retaining the same displayed width.
- Live acceptance checks passed for unsaved edits, actionable invalid-diagram
  notifications, correction, fence deletion/restoration, and unchanged source
  file/buffer contents. Scrolling and switching to an empty buffer left no stale
  images. A regular Markdown PNG also rendered correctly.
- Terminal resizing to 110 columns and splitting to 70 columns produced images
  103 and 63 columns wide respectively, fitting the text area. Both cases were
  checked by placement assertions and screenshots after the gutter correction.
- Merged configuration confirmed image.nvim Markdown integration disabled,
  Molten's image.nvim provider retained, Markview loaded, and math concealment
  unchanged. Inspected the zoom callback's explicit disabled integration.
- `:checkhealth snacks` confirmed Kitty placeholders/inline images, Markdown
  parsers, ImageMagick, `mmdc`, and Mermaid support. Unrelated existing warnings
  remain for optional parsers/SQLite; the picker reports missing `fd`/`fdfind`.
- Compared all pre-existing diffs with a saved baseline: unrelated changes and
  the user's visual-mode keymap edits were preserved exactly.

Follow-up on a duplicate-preview report: the user's older running Neovim session
had two Snacks virtual-image placements per visible Mermaid block and zero
image.nvim images in that buffer. Its renderer still used the old scale settings.
Cleared only that buffer's Snacks placements and redrew through its existing
update callback; the visible diagram then had one placement. Buffer text and
the unsaved/modified flag were preserved. The cause of the older session's
accumulated placements was not established; new-session checks did not reproduce
it. Restart Neovim to load the committed configuration.

Temporary evidence and test scripts: `/tmp/nvim-mermaid-LsK5i2/`, including
`ui-results.json`, `health.txt`, and `kitty-final.png`. These are local test
artifacts and may disappear after a reboot; results above are the durable record.

Limits: wrapped source in narrow splits uses Snacks' opening-fence placement
instead of the normal below-source position. Small labels remain inevitable in
very narrow windows. Notebook kernel execution, other terminals/OSes, and light
theme visuals were not tested. Existing math rendering was not changed or
visually retested. No persistent Markdown migration is needed.

Tradeoff: reuse the installed parser, renderer, and placement lifecycle with a
small configuration hook; no custom Mermaid plugin is maintained. Higher
resolution uses four times the raster pixels. Reconsider upstream layout work
only if wrapped-source placement is unacceptable.

Commit message: `feat(nvim): render sharper inline Mermaid diagrams (NVIM-1)`.
The user authorized a focused local commit. Push remains a manual user action;
no release or push performed. Git records the final commit hash.

This record starts with the current task; earlier history is in Git.


## NVIM-2 — Pomodoro pets (2026-11-09)

Implemented a local lazy-loaded Pomodoro plugin, Bash/Kitty desktop launcher,
minimal Neovim bootstrap, desktop-entry installer, shared settings, and tests.
The countdown and controls accompany the existing PetsADHD sidebar artwork.
Automatic 25/5/15 phases, four-focus long breaks, optional focus music and phase
alerts, atomic paused restore and kernel-managed exclusive ownership are included.
Spec and accepted boundary decision: [NVIM-2](docs/specs/pomodoro-pets.md).

Code: `lua/pomodoro/`, shared config and Lazy spec; launcher under `bin/`, bootstrap,
checks, installer and test runner under `scripts/`, desktop template and tests.
README and existing root/constitution records document operation and constraints.
No PetsADHD source or dependency revisions changed. Five pre-existing user diffs
remain intact, including the lockfile's unrelated dependency changes.

Verification performed:

- Fake-clock cycle, long-break, pause/resume, reset, late-tick and restore checks passed.
- Real renderer animation, resize fallback, theme events, hide/reopen and user-buffer
  preservation passed in Neovim. Exclusive ownership, atomic round-trip, corrupt save
  preservation and release/reacquisition after owner termination passed.
- Audio stubs verified focus/break/mute lifecycle, bounded alerts, cancellation,
  cleanup and suppression of automatic retries after a failed stream.
- Lazy.nvim command loading and dependency commands passed against installed
  PetsADHD fb91623 and lockfile-target 42b640d. The latter predates PetTerminal;
  tests check that command only on revisions which provide it.
- Launcher tests passed for arbitrary cwd, paths with spaces, invalid arguments,
  missing executables, desktop-entry validation, repeat installation and refusing
  unrelated files. Installed application-menu and Desktop entries on this machine.
- Real Kitty window inspected visually; shortened a clipped control legend.
  Short real phases advanced through focus/break and long-break cycles. Music
  streamed successfully; pause held remaining time steady. Alert FFplay exited 0;
  the original music process was absent after shutdown. A controlled two-launch
  GUI check confirmed exact paused restore and explicit --mute overriding saves.
- Lua syntax, targeted StyLua, Bash syntax, Python parsing and git diff checks passed.
  ShellCheck unavailable and skipped. Tests use the bundled Snap Neovim binary,
  because its wrapper fails in the automation sandbox. GUI tests required desktop access.

Limits: backend success does not prove a listener heard the audio. A physical click
on the installed Desktop shortcut was not verified. `gio launch` returned success
but was insufficient to confirm that instance, so the decisive restart test used
our Bash launcher directly. Full user configuration, other OSes and plugin upgrades
were not retested. Linux-only locking/signals; independent state scopes, no daemon.
Saved settings persist until reset, and crashes can lose up to five seconds.

Commit message: `feat(nvim): add Pomodoro pets and desktop launcher (NVIM-2)`.
User authorized commit and feature-branch push. Delivery result is recorded in Git
and the handoff; no merge or release requested.
