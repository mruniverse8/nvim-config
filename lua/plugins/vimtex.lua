return {
  {
    "lervag/vimtex",
    lazy = false, -- do not lazy-load VimTeX
    -- tag = "v2.15", -- optional: pin version

    init = function()
      if vim.fn.has("macunix") == 1 and vim.fn.executable("skim") == 1 then
        vim.g.vimtex_view_method = "skim"
      elseif vim.fn.executable("zathura") == 1 then
        vim.g.vimtex_view_method = "zathura"
      end
    end,
  },
}
