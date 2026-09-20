-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.cmd("colorscheme tokyonight")
-- vim.o.background = "light"
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
-- Disable swap files
vim.opt.swapfile = false

-- Optional: also disable backup/writebackup files
vim.opt.backup = false
vim.opt.writebackup = false

-- Enable automatic reload when files change outside Neovim
vim.opt.autoread = true

-- Check if file changed when entering buffer/window or gaining focus
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})
