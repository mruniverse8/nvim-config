local root = vim.env.POMODORO_ROOT
assert(root and root ~= "", "Launch using bin/pomodoro")
vim.opt.rtp:prepend(root)
local pets = vim.env.POMODORO_PETS_DIR or (vim.fn.stdpath("data") .. "/lazy/PetsADHD")
vim.opt.rtp:prepend(pets)
vim.o.termguicolors = true
vim.o.laststatus, vim.o.showtabline = 0, 0
vim.o.showmode, vim.o.ruler = false, false
vim.o.swapfile = false
vim.opt.fillchars:append({ eob = " " })
local opts = require("config.pomodoro")
for env, key in pairs({
  FOCUS = "focus_minutes",
  SHORT_BREAK = "short_break_minutes",
  LONG_BREAK = "long_break_minutes",
  CYCLES = "cycles",
}) do
  if vim.env["POMODORO_" .. env] then
    opts[key] = tonumber(vim.env["POMODORO_" .. env])
  end
end
if vim.env.POMODORO_MUTE == "1" then
  opts.music.enabled, opts.alerts.enabled = false, false
  opts.force_mute = true
end
opts.desktop = true
if vim.env.POMODORO_STATE_FILE then
  opts.state_file = vim.env.POMODORO_STATE_FILE
end
require("petsadhd.pets").setup({
  enabled = false,
  size = "small",
  keymaps = false,
  state_file = vim.fn.stdpath("state") .. "/pomodoro/desktop-pet",
})
require("pomodoro").setup(opts)
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    local ok, err = pcall(require("pomodoro").open)
    if not ok then
      vim.api.nvim_err_writeln(tostring(err))
      vim.cmd("cquit")
    end
  end,
})
