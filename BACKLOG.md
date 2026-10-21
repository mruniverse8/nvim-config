# Backlog

## NVIM-1 — Inline Mermaid in Markdown (implemented and verified, 2026-10-21)

Problem: Snacks document images are enabled, but `mmdc` is missing. Mermaid
fences should display diagrams below their visible source in Kitty.

Implement with the installed Snacks plugin, Mermaid CLI, and existing Markdown
parsers. Keep the supplied diagrams' `flowchart LR` layout. Retain math
concealment, PDFReader, and image.nvim for notebook output. Prevent the legacy
image zoom callback from enabling a second Markdown image renderer.

No custom plugin, browser preview, diagram rewriting, or plugin upgrades.
Generated images belong in the Snacks cache, not the Markdown document.
Requested refinement: render at twice the terminal's normal pixel density for
sharper labels and edges, keeping the same inline size.
Resize verification exposed clipping at the right gutter. Use Snacks' existing
placement callback and automatic resize support to fit the actual text area.
Invalid Mermaid must report an error without preventing editing; correction
must restore rendering. Wide diagrams may have small labels when scaled down.

Acceptance criteria:

- AC-1: Both supplied examples render below their respective visible fences in Kitty.
- AC-2: Editing updates the preview without changing Markdown file contents.
- AC-3: Scrolling, resizing, switching buffers, and deleting a block leave no stale images.
- AC-4: Invalid Mermaid reports an actionable error; correcting it restores rendering.
- AC-5: Markview and ordinary document images coexist; image.nvim notebook settings
  remain compatible and zoom shortcuts cannot activate duplicate Markdown rendering.

Checks: Lua syntax/configuration, CLI rendering of both examples, parser
extraction, failure/recovery, and a real Kitty visual check when available.
Record actual evidence and unverified criteria in CHANGES.md.

Results: rendering, unsaved edits, invalid syntax/recovery, deletion/restoration,
scrolling, buffer switching, terminal/split resizing, regular PNGs, and merged
plugin settings passed. See CHANGES.md for evidence and verification bounds.

Known layout limitation: AC-1's below-source position holds at the tested 160-
and 110-column terminal widths. With wrapped source in a 70-column split, the
installed Snacks version places charts near the opening fence instead. Source
remains visible and editable. Fixing that upstream layout behavior is outside
this configuration-only change; widen the split to retain below-source placement.

Width refinement (2026-10-21, implemented): raise the preview cap from 120 to
160 columns at the user's request. Acceptance: use the extra width when available,
retain the 40-row cap and 2x pixel density, and continue fitting within the text
area on narrower windows. Lua syntax, StyLua, and diff checks passed; the live
session's width setting was updated without changing source or modified state.
No diagrams were in its visible viewport during this follow-up, so actual wider
placements were not visually retested. The existing width-clamping logic is unchanged.
