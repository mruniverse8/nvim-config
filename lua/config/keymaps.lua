-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
---- Move between Neovim windows with Ctrl+a + arrows
vim.keymap.set("n", "<C-a><Left>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-a><Right>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("n", "<C-a><Up>", "<C-w>k", { desc = "Move to upper window" })
vim.keymap.set("n", "<C-a><Down>", "<C-w>j", { desc = "Move to lower window" })

-- Same mappings from terminal mode
vim.keymap.set("t", "<C-a><Left>", [[<C-\><C-n><C-w>h]], { desc = "Move to left window" })
vim.keymap.set("t", "<C-a><Right>", [[<C-\><C-n><C-w>l]], { desc = "Move to right window" })
vim.keymap.set("t", "<C-a><Up>", [[<C-\><C-n><C-w>k]], { desc = "Move to upper window" })
vim.keymap.set("t", "<C-a><Down>", [[<C-\><C-n><C-w>j]], { desc = "Move to lower window" })

-- Ctrl+a b → create new buffer
vim.keymap.set("n", "<C-a>b", "<cmd>enew<CR>", { desc = "New buffer" })

-- Ctrl+a d → delete current buffer
vim.keymap.set("n", "<C-a>d", "<cmd>lua Snacks.bufdelete()<CR>", { desc = "Delete buffer" })
-- Ctrl+b Tab → next buffer
vim.keymap.set("n", "<C-b><Tab>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- Ctrl+b Shift+Tab → previous buffer
vim.keymap.set("n", "<C-b><S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<leader>t", "<cmd>terminal<CR>", { desc = "Open terminal (full)" })

vim.keymap.set("n", "<leader><Right>", ":bnext<CR>", {
  desc = "Next buffer",
  silent = true,
})

vim.keymap.set("n", "<leader><Left>", ":bprevious<CR>", {
  desc = "Previous buffer",
  silent = true,
})

-- Exit terminal mode with Ctrl+Space or Ctrl+Shift+Space
vim.keymap.set("t", "<C-Space>", [[<C-\><C-n>]], {
  noremap = true,
  silent = true,
  desc = "Exit terminal mode",
})
vim.keymap.set("t", "<C-S-Space>", [[<C-\><C-n>]], {
  noremap = true,
  silent = true,
  desc = "Exit terminal mode",
})
-- Move to buffer by visible BufferLine position
vim.keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>", {
  desc = "Go to Buffer 1",
})

vim.keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>", {
  desc = "Go to Buffer 2",
})

vim.keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>", {
  desc = "Go to Buffer 3",
})

vim.keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>", {
  desc = "Go to Buffer 4",
})

local image_zoom_level = 1

local image_zoom_profiles = {
  {
    max_width = 80,
    max_height = 20,
    max_width_window_percentage = 50,
    max_height_window_percentage = 50,
  },
  {
    max_width = 120,
    max_height = 40,
    max_width_window_percentage = 80,
    max_height_window_percentage = 70,
  },
  {
    max_width = 180,
    max_height = 60,
    max_width_window_percentage = 90,
    max_height_window_percentage = 90,
  },
}

local function reload_image_nvim()
  -- Reload after changing image.nvim output sizing (Markdown uses Snacks).
  vim.cmd("edit")
end

local function set_image_zoom(level)
  image_zoom_level = math.max(1, math.min(level, #image_zoom_profiles))

  local profile = image_zoom_profiles[image_zoom_level]

  require("image").setup({
    backend = "kitty",
    integrations = {
      markdown = {
        enabled = false, -- Snacks owns Markdown images, including Mermaid.
      },
    },
    max_width = profile.max_width,
    max_height = profile.max_height,
    max_width_window_percentage = profile.max_width_window_percentage,
    max_height_window_percentage = profile.max_height_window_percentage,
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" },
  })

  reload_image_nvim()

  vim.notify("image.nvim zoom: " .. profile.max_width .. "x" .. profile.max_height .. " cells", vim.log.levels.INFO)
end

vim.keymap.set("n", "<leader>i+", function()
  set_image_zoom(image_zoom_level + 1)
end, { desc = "Image.nvim zoom in" })

vim.keymap.set("n", "<leader>i-", function()
  set_image_zoom(image_zoom_level - 1)
end, { desc = "Image.nvim zoom out" })

vim.keymap.set("n", "<leader>i0", function()
  set_image_zoom(1)
end, { desc = "Image.nvim reset zoom" })
