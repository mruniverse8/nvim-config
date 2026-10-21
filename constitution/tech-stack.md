# Technology and constraints

- Lua configuration with Lazy.nvim and LazyVim; revisions in `lazy-lock.json`.
- Markview renders Markdown; the duplicate render-markdown plugin is disabled.
- Snacks handles document images through Kitty graphics and Tree-sitter queries.
- image.nvim serves Molten notebook output; PDFReader handles PDF buffers.
- ImageMagick supplies image conversion/metadata. Mermaid CLI (`mmdc`) is the
  local diagram dependency and uses Puppeteer with a headless browser. Verified
  versions: CLI 12.0.0, Mermaid 12.2.0, Puppeteer 25.15.0.
- The README documents Neovim 0.11.2+ with LuaJIT. The current machine has Kitty
  0.49.2, Node 22.23.1, npm 10.9.8, and ImageMagick 6.9.12-98.

Keep optional executables and generated caches outside Git. Reuse the installed
Snacks implementation; NVIM-1 does not require a new plugin or plugin updates.
