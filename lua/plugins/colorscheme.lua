return {
  {
    "neanias/everforest-nvim",
    version = false,
    lazy = false,
    priority = 900,

    config = function()
      -- Everforest background mode:
      -- vim.o.background = "light" -- light Everforest
      -- vim.o.background = "dark"  -- dark Everforest

      vim.o.background = "light"

      --require("everforest").setup({
      -- Everforest contrast options:
      -- background = "soft",
      --  background = "medium",
      -- background = "hard",

      --background = "hard",
      --})

      -- Enable this only if you want Everforest as default:
      -- vim.cmd.colorscheme("everforest")
    end,
  },

  {
    "talha-akram/noctis.nvim",
    lazy = false,
    priority = 1000,
  },

  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      -- DEFAULT: Noctis Obscuro
      -- colorscheme = function()
      --   vim.o.background = "dark"
      --   vim.cmd.colorscheme("noctis_obscuro")
      -- end,

      -- Easy switch options:

      -- Noctis dark / default
      -- colorscheme = "noctis",

      -- Noctis very dark
      -- colorscheme = "noctis_obscuro",
      --
      -- Noctis other dark variants
      -- colorscheme = "noctis_azureus",
      -- colorscheme = "noctis_bordo",
      -- colorscheme = "noctis_minimus",
      -- colorscheme = "noctis_uva",
      -- colorscheme = "noctis_viola",

      -- Noctis light variants
      -- colorscheme = "noctis_lux",
      -- colorscheme = "noctis_hibernus",
      -- colorscheme = "noctis_lilac",

      --Everforest light hard
      colorscheme = function()
        vim.o.background = "light"
        vim.cmd.colorscheme("everforest")
      end,

      --Everforest dark hard
      -- colorscheme = function()
      --   vim.o.background = "dark"
      --   vim.cmd.colorscheme("everforest")
      -- end,

      --Gruvbox dark
      -- colorscheme = function()
      --   vim.o.background = "dark"
      --   vim.cmd.colorscheme("gruvbox")
      -- end,

      -- Gruvbox light
      -- colorscheme = function()
      --   vim.o.background = "light"
      --   vim.cmd.colorscheme("gruvbox")
      -- end,
    },
  },
}
