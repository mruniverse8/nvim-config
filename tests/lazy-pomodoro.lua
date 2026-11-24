vim.go.loadplugins = true -- -u NONE disables loading
local root = vim.fn.getcwd()
vim.opt.rtp:prepend(root)
local data = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.rtp:prepend(data .. "lazy.nvim")
local spec = require("plugins.pomodoro")
spec[#spec + 1] = {
  name = "PetsADHD",
  dir = vim.env.POMODORO_PETS_DIR or data .. "PetsADHD",
  main = "petsadhd",
  opts = { snacks = false, keymaps = false, music = false, pets = { enabled = false, state_file = "/dev/null" } },
}
spec[1].opts =
  { state_file = vim.fn.tempname() .. "/lazy.json", music = { enabled = false }, alerts = { enabled = false } }
require("lazy").setup({
  spec = spec,
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  lockfile = vim.fn.tempname(),
  performance = { reset_packpath = false },
})
assert(not package.loaded["pomodoro"], "plugin lazy before command")
vim.cmd("Pomodoro pause")
assert(package.loaded["pomodoro"] and require("pomodoro").status(), "command loads local plugin")
assert(vim.fn.exists(":PetTRex") == 2, "existing pet selection command")
if vim.uv.fs_stat((vim.env.POMODORO_PETS_DIR or data .. "PetsADHD") .. "/lua/petsadhd/terminal.lua") then
  assert(vim.fn.exists(":PetTerminal") == 2, "existing terminal command")
end
require("pomodoro").close()
print("PASS Lazy.nvim command trigger and dependency integration")
vim.cmd("qa!")
