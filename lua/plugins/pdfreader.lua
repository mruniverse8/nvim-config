return {
  {
    "r-pletnev/pdfreader.nvim",
    lazy = false,
    dependencies = {
      "folke/snacks.nvim",
      { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    config = function()
      -- Keep PDF bytes out of the buffer; PDFReader renders the pages on BufEnter.
      vim.api.nvim_create_autocmd("BufReadCmd", {
        group = vim.api.nvim_create_augroup("pdfreader_buffers", { clear = true }),
        pattern = "*.pdf",
        callback = function(event)
          vim.bo[event.buf].buftype = "nofile"
          vim.bo[event.buf].swapfile = false
          vim.bo[event.buf].filetype = "pdf"
        end,
      })
      require("pdfreader").setup()
    end,
  },
}
