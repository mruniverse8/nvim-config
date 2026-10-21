# Checkpoint

Objective: NVIM-1, render Mermaid diagrams beneath visible Markdown source in Kitty.

Latest existing commit when preparing this task's commit:
`2e004dd46fe08181ad277b01e7e94a32d23233bf` (NVIM-1's base).
The user authorized committing NVIM-1; unrelated changes remain uncommitted.
Git records the resulting hash to avoid embedding this document's own commit hash.

Completed: configured Snacks inline diagrams, 2x pixel density, visible source,
conversion-error notifications, and fitting to the usable text area on resize.
Corrected the legacy zoom callback; installed Mermaid CLI and its browser;
added README examples and setup documentation. Actual CLI, configuration, and
Kitty visual/interaction checks passed within the bounds recorded in CHANGES.md.
Also cleared duplicate Snacks placements in the user's older running Markdown
session without changing its source or modified flag; it still needs a restart
to load the final renderer settings.

No remaining implementation work for the agreed configuration approach.
Known limitation: wrapped source in narrow splits moves the preview near the
opening fence; below-source placement is verified at 160/110 terminal columns.
Live notebook execution and other OS/terminal combinations remain untested.

Pre-existing uncommitted changes to preserve: `README-kitty.md`,
`kitty/kitty.conf`, `lazy-lock.json`, `lua/config/keymaps.lua` (visual-mode keys),
and `lua/plugins/colorscheme.lua`.
Task changes: `lua/plugins/snacks.lua`, the image.nvim callback/comment in
`lua/config/keymaps.lua`, README dependencies/examples, root tracking records,
and `constitution/` context. Generated images and test artifacts are outside Git.

Environment: `~/.config/nvim` links to this repository. The `nvim` Snap wrapper
fails in the automation environment; the bundled binary runs directly at
`/snap/nvim/current/usr/bin/nvim` (0.13.0 development build). Use the matching
`VIMRUNTIME` for isolated checks. Do not change the user's Neovim installation.

Next: restart the user's existing Neovim session to load the configuration and
open the README examples. Push the local commit when ready with
`git -C /home/biorn/Documents/nvim-config push origin main`.
Commit message: `feat(nvim): render sharper inline Mermaid diagrams (NVIM-1)`.
