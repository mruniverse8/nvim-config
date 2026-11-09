local M = {}
local app, options
local ns = vim.api.nvim_create_namespace("PomodoroPets")
local function defaults(opts)
  local o = vim.tbl_deep_extend("force", require("config.pomodoro"), opts or {})
  for _, key in ipairs({ "focus_minutes", "short_break_minutes", "long_break_minutes" }) do
    assert(type(o[key]) == "number" and o[key] > 0 and o[key] <= 1440, "Pomodoro: invalid " .. key)
  end
  assert(
    type(o.cycles) == "number" and o.cycles >= 1 and o.cycles <= 100 and o.cycles % 1 == 0,
    "Pomodoro: invalid cycles"
  )
  for _, key in ipairs({ "music", "alerts" }) do
    assert(type(o[key].volume) == "number" and o[key].volume >= 0 and o[key].volume <= 100, "Pomodoro: invalid volume")
  end
  return o
end
local function save()
  if not app then
    return
  end
  local s = app.timer:snapshot()
  s.music, s.alerts = app.audio.music, app.audio.alerts
  app.store:write(s)
end
local function render()
  if not app or not app.win or not vim.api.nvim_win_is_valid(app.win) then
    return
  end
  local width = math.max(1, math.min(60, vim.o.columns - 4))
  local height = math.max(1, math.min(17, vim.o.lines - 4))
  vim.api.nvim_win_set_config(app.win, {
    relative = "editor",
    row = 1,
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    width = width,
    height = height,
  })
  local t = app.timer
  local seconds = math.ceil(t.remaining)
  local lines = {
    "Pomodoro pets • " .. t.phase:gsub("_", " ") .. (t.running and "" or " [paused]"),
    string.format("%02d:%02d   •   %d focus sessions", math.floor(seconds / 60), seconds % 60, t.completed),
  }
  local bar = math.max(1, width - 2)
  local done = math.floor(bar * math.min(1, math.max(0, 1 - t.remaining / t.durations[t.phase])))
  lines[#lines + 1] = string.rep("━", done) .. string.rep("·", bar - done)
  local offset, spans = #lines, {}
  if width >= 20 and height >= 12 then
    local pets, hl = require("petsadhd.pets").render(width, app.frame)
    if #pets <= height - 5 then
      vim.list_extend(lines, pets)
      spans = hl
    end
  end
  lines[#lines + 1] = "Music "
    .. (app.audio.music and "on" or "off")
    .. " • alerts "
    .. (app.audio.alerts and "on" or "off")
  lines[#lines + 1] = width >= 48 and "Space pause | r reset | n pet | m music | a alerts | q"
    or "Space pause | r n m a q"
  vim.bo[app.buf].modifiable = true
  vim.api.nvim_buf_set_lines(app.buf, 0, -1, false, lines)
  vim.bo[app.buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(app.buf, ns, 0, -1)
  for _, span in ipairs(spans) do
    vim.api.nvim_buf_set_extmark(app.buf, ns, offset + span[1], span[2], { end_col = span[3], hl_group = span[4] })
  end
end
function M.close()
  if not app then
    return
  end
  app.timer:pause()
  save()
  app.audio:close()
  app.ticker:stop()
  app.ticker:close()
  app.store:close()
  if app.win and vim.api.nvim_win_is_valid(app.win) then
    vim.api.nvim_win_close(app.win, true)
  end
  if app.buf and vim.api.nvim_buf_is_valid(app.buf) then
    vim.api.nvim_buf_delete(app.buf, { force = true })
  end
  app = nil
end
local function ensure()
  if app then
    return
  end
  options = defaults(options)
  local path = options.state_file
    or (
      vim.fn.stdpath("state")
      .. "/pomodoro/"
      .. (options.desktop and "desktop" or "editor-" .. vim.fn.sha256(vim.fn.getcwd()):sub(1, 16))
      .. ".json"
    )
  local store = require("pomodoro.state").open(path)
  local saved, invalid = store:read()
  local audio = require("pomodoro.audio").new(options)
  if saved then
    audio.music, audio.alerts = saved.music, saved.alerts
  end
  if options.force_mute then
    audio.music, audio.alerts = false, false
  end
  app = { store = store, audio = audio, frame = 0, last_save = 0 }
  app.timer = require("pomodoro.timer").new(options, function()
    return vim.uv.hrtime() / 1e9
  end, function()
    audio:alert()
  end, saved)
  if invalid then
    app.timer:pause()
  end
  app.ticker = assert(vim.uv.new_timer())
  local owner = app
  app.ticker:start(
    0,
    250,
    vim.schedule_wrap(function()
      if app ~= owner then
        return
      end
      local transitioned = app.timer:tick()
      app.audio:update(app.timer)
      app.frame = app.frame + 1
      if transitioned or app.frame - app.last_save >= 20 then
        save()
        app.last_save = app.frame
      end
      render()
    end)
  )
  save()
end
function M.action(action)
  if action and action ~= "" and not vim.tbl_contains({ "start", "pause", "resume", "reset", "stop" }, action) then
    error("Pomodoro: unknown action " .. action)
  end
  ensure()
  local t = app.timer
  if action == "pause" or action == "stop" then
    t:pause()
  elseif action == "start" or action == "resume" then
    t:resume()
  elseif action == "reset" then
    t:reset()
  elseif action ~= nil and action ~= "" then
    error("Pomodoro: unknown action " .. action)
  end
  app.audio:update(t)
  save()
  render()
  if action == "stop" then
    M.hide()
  end
end
function M.hide()
  if options.desktop then
    M.close()
    vim.cmd("qa!")
    return
  end
  if app and app.win and vim.api.nvim_win_is_valid(app.win) then
    vim.api.nvim_win_close(app.win, true)
  end
end
function M.open(action)
  M.action(action)
  if action == "stop" then
    return
  end
  if app.win and vim.api.nvim_win_is_valid(app.win) then
    vim.api.nvim_set_current_win(app.win)
    return
  end
  if not app.buf or not vim.api.nvim_buf_is_valid(app.buf) then
    app.buf = vim.api.nvim_create_buf(false, true)
  end
  vim.bo[app.buf].bufhidden = "hide"
  vim.bo[app.buf].filetype = "pomodoro"
  app.win = vim.api.nvim_open_win(
    app.buf,
    true,
    { relative = "editor", row = 1, col = 1, width = 30, height = 12, style = "minimal", border = "rounded" }
  )
  vim.wo[app.win].wrap = false
  local function bind(key, fn)
    vim.keymap.set("n", key, fn, { buffer = app.buf, nowait = true })
  end
  bind("<Space>", function()
    M.action(app.timer.running and "pause" or "resume")
  end)
  bind("r", function()
    M.action("reset")
  end)
  bind("q", M.hide)
  bind("m", function()
    app.audio:toggle()
    app.audio:update(app.timer)
    save()
    render()
  end)
  bind("a", function()
    app.audio.alerts = not app.audio.alerts
    save()
    render()
  end)
  bind("n", function()
    local pets = require("petsadhd.pets")
    local kinds = { "trex", "dog", "duck", "sixseven" }
    local index = 1
    for i, kind in ipairs(kinds) do
      if pets.kind() == kind then
        index = i
      end
    end
    pets.select(kinds[index % #kinds + 1])
    render()
  end)
  render()
end
function M.status()
  if not app then
    return nil
  end
  local s = app.timer:snapshot()
  s.running, s.music, s.alerts, s.audio_status =
    app.timer.running, app.audio.music, app.audio.alerts, app.audio.controller.status
  return s
end
function M.setup(opts)
  options = defaults(opts)
  vim.api.nvim_create_user_command("Pomodoro", function(args)
    local ok, err = pcall(M.open, args.args)
    if not ok then
      vim.notify(tostring(err), vim.log.levels.ERROR)
    end
  end, {
    nargs = "?",
    complete = function()
      return { "start", "pause", "resume", "reset", "stop" }
    end,
  })
  local group = vim.api.nvim_create_augroup("Pomodoro", { clear = true })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.close })
  vim.api.nvim_create_autocmd({ "VimResized", "ColorScheme" }, {
    group = group,
    callback = function()
      vim.schedule(render)
    end,
  })
end
return M
