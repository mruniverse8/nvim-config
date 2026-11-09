vim.opt.rtp:prepend(vim.fn.getcwd())
vim.opt.rtp:prepend(vim.env.POMODORO_PETS_DIR or (vim.fn.stdpath("data") .. "/lazy/PetsADHD"))
local opts = require("config.pomodoro")
local now, boundaries = 0, 0
local engine = require("pomodoro.timer")
local t = engine.new(opts, function()
  return now
end, function()
  boundaries = boundaries + 1
end)
now = 90
t:pause()
assert(t.remaining == 1410)
now = 999
t:tick()
assert(t.remaining == 1410)
t:resume()
now = now + 1410
t:tick()
assert(t.phase == "short_break" and t.completed == 1)
for i = 2, 4 do
  now = now + t.remaining
  t:tick()
  assert(t.phase == "focus")
  now = now + t.remaining
  t:tick()
  assert(t.phase == (i == 4 and "long_break" or "short_break"))
end
assert(boundaries == 7 and t.remaining == 900)
now = now + 100000
t:tick()
assert(t.phase == "focus" and t.remaining == 1500 and boundaries == 8)
local restored = engine.new(opts, function()
  return now
end, nil, t:snapshot())
assert(not restored.running and restored.completed == 4)
t:reset()
assert(t.phase == "focus" and t.remaining == 1500 and t.completed == 0 and not t.running)
print("PASS AC-1: deadlines, cycles, pause, late tick, reset and restore")
local root = vim.fn.tempname() .. " with spaces"
vim.fn.mkdir(root, "p")
local state = require("pomodoro.state")
local path = root .. "/session.json"
local store = state.open(path)
local busy = pcall(state.open, path)
assert(not busy, "exclusive lock")
local snap = t:snapshot()
snap.music, snap.alerts = false, true
store:write(snap)
local read = store:read()
assert(read.phase == "focus" and not read.music)
store:close()
store = state.open(path)
assert(store:read().completed == 0)
vim.fn.writefile({ "{bad" }, path)
local bad, invalid = store:read()
assert(not bad and invalid)
assert(#vim.fn.glob(path .. ".invalid-*", false, true) == 1)
store:close()
-- Kernel lock recovery after a terminated owner job.
store = state.open(path)
vim.fn.jobstop(store.lock)
vim.fn.jobwait({ store.lock }, 1000)
store:close()
store = state.open(path)
store:close()
print("PASS AC-4: atomic save, corruption preservation, exclusive and released locks")
local sounds = {}
package.loaded["petsadhd.audio"] = {
  new = function()
    local sound = { status = "off", starts = 0 }
    function sound:start()
      self.starts = self.starts + 1
      self.status = "playing"
    end
    function sound:pause(value)
      self.paused = value
    end
    function sound:stop()
      self.stopped = true
      self.status = "off"
    end
    sounds[#sounds + 1] = sound
    return sound
  end,
}
local a = require("pomodoro.audio").new(opts)
a:update({ running = true, phase = "focus" })
assert(not sounds[1].paused)
a:update({ running = true, phase = "short_break" })
assert(sounds[1].paused)
a:toggle()
a:update({ running = true, phase = "focus" })
assert(sounds[1].paused and sounds[1].stopped)
a:toggle()
sounds[1].status = "unavailable"
local starts = sounds[1].starts
a:update({ running = true, phase = "focus" })
assert(sounds[1].starts == starts, "no retry storm")
a:close()
assert(sounds[1].stopped)
local original_start, original_stop = vim.fn.jobstart, vim.fn.jobstop
local started, stopped = {}, {}
vim.fn.jobstart = function(argv, callbacks)
  started[#started + 1] = { argv, callbacks }
  return 100 + #started
end
vim.fn.jobstop = function(job)
  stopped[job] = true
end
a = require("pomodoro.audio").new(opts)
a:alert()
a:alert()
assert(#started == 2 and stopped[101] and started[1][1][1] == "ffplay")
a.alerts = false
a:alert()
assert(#started == 2)
a:close()
assert(stopped[102])
vim.fn.jobstart, vim.fn.jobstop = original_start, original_stop
print("PASS AC-3: focus music, mute, bounded alerts, failure retry and cleanup")
require("petsadhd.pets").setup({ enabled = false, size = "small", keymaps = false, state_file = root .. "/pet" })
local pomodoro = require("pomodoro")
opts.state_file = root .. "/ui.json"
opts.music.enabled = false
opts.alerts.enabled = false
pomodoro.setup(opts)
vim.o.columns, vim.o.lines = 80, 30
local editor = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(editor, 0, -1, false, { "Preserve my work" })
local function command(args)
  vim.cmd("Pomodoro " .. (args or ""))
end
command()
local panel = vim.api.nvim_get_current_buf()
assert(vim.bo[panel].filetype == "pomodoro")
local first = vim.api.nvim_buf_get_lines(panel, 0, -1, false)
assert(#first >= 12 and table.concat(first):find("25:00", 1, true))
assert(vim.wait(1200, function()
  return not vim.deep_equal(first, vim.api.nvim_buf_get_lines(panel, 0, -1, false))
end, 20))
command("pause")
pomodoro.hide()
assert(vim.api.nvim_get_current_buf() == editor)
command()
assert(vim.api.nvim_get_current_buf() == panel)
vim.o.columns, vim.o.lines = 24, 12
vim.api.nvim_exec_autocmds("VimResized", {})
vim.wait(300, function()
  return false
end)
assert(#vim.api.nvim_buf_get_lines(panel, 0, -1, false) == 5)
vim.api.nvim_exec_autocmds("ColorScheme", {})
command("reset")
pomodoro.close()
assert(vim.api.nvim_buf_get_lines(editor, 0, -1, false)[1] == "Preserve my work")
local saved = vim.json.decode(table.concat(vim.fn.readfile(opts.state_file)))
assert(saved.remaining == 1500 and saved.completed == 0)
saved.music, saved.alerts = true, true
vim.fn.writefile({ vim.json.encode(saved) }, opts.state_file)
opts.force_mute = true
pomodoro.setup(opts)
command()
assert(not pomodoro.status().music and not pomodoro.status().alerts, "explicit mute overrides saved preferences")
assert(table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), 0, -1, false)):find("[paused]", 1, true))
pomodoro.close()
print("PASS AC-2/AC-6: real animation, resizing, themes, hide/reopen, paused restore, buffers preserved")
vim.fn.delete(root, "rf")
vim.cmd("qa!")
