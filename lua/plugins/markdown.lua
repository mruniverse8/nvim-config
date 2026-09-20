return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- Markview already renders these buffers; using both covers heading text.
    enabled = false,
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
      -- or: "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
