return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = true,
          max_width = 120,
          max_height = 40,
          auto_resize = true,
          on_update_pre = function(placement)
            -- Reserve the number/sign columns and the image's indentation.
            local width = 120
            for _, win in ipairs(placement:wins()) do
              local info = vim.fn.getwininfo(win)[1]
              width = math.min(width, info.width - info.textoff - placement.opts.pos[2])
            end
            placement.opts.max_width = math.max(1, width)
          end,
          -- Keep Mermaid source visible; retain Snacks' math concealment.
          conceal = function(_, kind)
            return kind == "math"
          end,
        },
        convert = {
          notify = true,
          mermaid = function()
            local theme = vim.o.background == "light" and "neutral" or "dark"
            -- Supersample text and edges without enlarging the inline preview.
            local scale = (Snacks.image.terminal.size().scale or 1) * 2
            return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", tostring(scale) }
          end,
        },
        -- PDFReader handles PDF buffers; Snacks handles other images.
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
          "heic",
          "avif",
          "mp4",
          "mov",
          "avi",
          "mkv",
          "webm",
          "icns",
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
