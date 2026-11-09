local M = {}
local function valid(s)
  if type(s) ~= "table" or s.version ~= 1 or type(s.durations) ~= "table" then
    return false
  end
  for _, phase in ipairs({ "focus", "short_break", "long_break" }) do
    local n = s.durations[phase]
    if type(n) ~= "number" or n <= 0 or n > 86400 then
      return false
    end
  end
  return s.durations[s.phase] ~= nil
    and type(s.remaining) == "number"
    and s.remaining >= 0
    and s.remaining <= s.durations[s.phase]
    and type(s.completed) == "number"
    and s.completed >= 0
    and s.completed % 1 == 0
    and type(s.cycles) == "number"
    and s.cycles >= 1
    and s.cycles <= 100
    and s.cycles % 1 == 0
    and type(s.music) == "boolean"
    and type(s.alerts) == "boolean"
end
function M.open(path)
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
  -- flock is held by a child reading stdin. Kernel ownership expires on crashes.
  local lock = vim.fn.jobstart(
    { "flock", "-n", "-E", "75", path .. ".lock", "sh", "-c", "printf 'ready\n'; cat >/dev/null" },
    {
      stdout_buffered = false,
      on_stdout = function(_, lines)
        for _, line in ipairs(lines) do
          if line == "ready" then
            M._ready[path] = true
          end
        end
      end,
    }
  )
  if lock <= 0 then
    error("Pomodoro: could not start flock")
  end
  M._ready[path] = nil
  local ready = vim.wait(2000, function()
    return M._ready[path] or vim.fn.jobwait({ lock }, 0)[1] ~= -1
  end, 10)
  if not ready or not M._ready[path] then
    vim.fn.jobstop(lock)
    error("Pomodoro: state is already in use (or flock failed): " .. path)
  end
  local self = { path = path, lock = lock }
  function self:read()
    if vim.fn.filereadable(path) == 0 then
      if vim.uv.fs_stat(path) then
        self.readonly = true
        vim.notify("Pomodoro: saved state is unreadable; keeping it untouched", vim.log.levels.WARN)
        return nil, true
      end
      return nil
    end
    local ok, s = pcall(function()
      return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
    end)
    if ok and valid(s) then
      return s
    end
    local backup = path .. ".invalid-" .. os.time() .. "-" .. vim.fn.getpid()
    local moved = vim.uv.fs_rename(path, backup)
    if not moved then
      self.readonly = true
    end
    vim.notify(
      "Pomodoro: invalid saved state; starting paused. Original " .. (moved and backup or path),
      vim.log.levels.WARN
    )
    return nil, true
  end
  function self:write(s)
    if self.readonly then
      return
    end
    s.version = 1
    local temp = path .. "." .. vim.fn.getpid() .. ".tmp"
    local ok, err = pcall(function()
      assert(vim.fn.writefile({ vim.json.encode(s) }, temp) == 0)
      assert(vim.uv.fs_rename(temp, path))
    end)
    if not ok and not self.warned then
      self.warned = true
      vim.notify("Pomodoro: save failed: " .. tostring(err), vim.log.levels.WARN)
    end
    if not ok then
      vim.fn.delete(temp)
    end
  end
  function self:close()
    if self.lock then
      pcall(vim.fn.chanclose, self.lock, "stdin")
      vim.fn.jobwait({ self.lock }, 500)
      pcall(vim.fn.jobstop, self.lock)
      self.lock = nil
      M._ready[path] = nil
    end
  end
  return self
end
M._ready = {}
return M
