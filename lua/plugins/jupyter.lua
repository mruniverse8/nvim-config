return {
  -- Open/edit .ipynb notebooks in Neovim using Jupytext
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false, -- important: load before opening .ipynb files
    opts = {
      style = "hydrogen",
      -- Force Python output instead of "auto". Colab notebooks omit the
      -- 'language_info.file_extension' metadata that "auto" needs, which
      -- makes jupytext fail with E5108. "py" sidesteps that entirely.
      output_extension = "py",
      force_ft = "python",
    },
  },

  -- Run notebook/Python cells with a Jupyter kernel
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = { "python", "markdown", "ipynb" },
    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_win_max_height = 20

      -- If you use Kitty and want image output:
      vim.g.molten_image_provider = "image.nvim"

      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    dependencies = {
      "3rd/image.nvim",
    },
  },

  -- Image support for plots/figures in Kitty
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
        },
      },
    },
  },
}
