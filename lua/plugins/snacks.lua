return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = { enabled = true },
        -- PDFReader handles PDF buffers; Snacks handles other images.
        formats = {
          "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff",
          "heic", "avif", "mp4", "mov", "avi", "mkv", "webm", "icns",
        },
      },
    },
  },
  {
    "3rd/image.nvim",
    -- Snacks renders document images; keep image.nvim for Molten output.
    opts = { integrations = { markdown = { enabled = false } } },
  },
}
