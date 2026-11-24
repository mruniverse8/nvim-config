local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
return {
  {
    dir = root,
    name = "pomodoro.nvim",
    main = "pomodoro",
    lazy = true,
    dependencies = { "PetsADHD" },
    cmd = "Pomodoro",
    keys = { { "<leader>uO", "<cmd>Pomodoro<cr>", desc = "Pomodoro pets" } },
    opts = function()
      return require("config.pomodoro")
    end,
  },
}
