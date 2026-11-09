vim.opt.rtp:prepend(vim.env.POMODORO_ROOT)
local path = vim.env.POMODORO_PETS_DIR or (vim.fn.stdpath("data") .. "/lazy/PetsADHD")
vim.opt.rtp:prepend(path)
local ok, pets = pcall(require, "petsadhd.pets")
if not ok or type(pets.render) ~= "function" then
  print("Missing PetsADHD renderer: install the configured plugin using Lazy, or set POMODORO_PETS_DIR")
  vim.cmd("cquit")
end
assert(vim.fn.has("nvim-0.11") == 1, "Neovim 0.11+ required")
assert(vim.fn.executable("flock") == 1, "flock required")
print("Pomodoro: Neovim, Kitty, flock and PetsADHD available")
for _, name in ipairs({ "ffplay", "node" }) do
  print(name .. (vim.fn.executable(name) == 1 and ": available" or ": missing (optional audio dependency)"))
end
local extractor = vim.fn.stdpath("data") .. "/invaders-audio/bin/yt-dlp"
print(
  "yt-dlp: "
    .. (
      (vim.fn.executable(extractor) == 1 or vim.fn.executable("yt-dlp") == 1) and "available"
      or "missing (optional music dependency)"
    )
)
vim.cmd("qa!")
