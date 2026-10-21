# Changes

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
