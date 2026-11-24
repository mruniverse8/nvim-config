-- Pure state machine. Clock and phase callback are supplied by the host.
local M = {}
function M.new(opts, clock, changed, saved)
  local durations = {
    focus = opts.focus_minutes * 60,
    short_break = opts.short_break_minutes * 60,
    long_break = opts.long_break_minutes * 60,
  }
  local s = saved or { phase = "focus", remaining = durations.focus, completed = 0 }
  local self = {
    phase = s.phase,
    remaining = s.remaining,
    completed = s.completed,
    running = not saved,
    durations = s.durations or durations,
    cycles = s.cycles or opts.cycles,
  }
  local deadline = clock() + self.remaining
  function self:tick()
    if not self.running then
      return false
    end
    self.remaining = math.max(0, deadline - clock())
    if self.remaining > 0 then
      return false
    end
    if self.phase == "focus" then
      self.completed = self.completed + 1
      self.phase = self.completed % self.cycles == 0 and "long_break" or "short_break"
    else
      self.phase = "focus"
    end
    self.remaining = self.durations[self.phase]
    deadline = clock() + self.remaining
    if changed then
      changed(self)
    end
    return true
  end
  function self:pause()
    self:tick()
    self.running = false
  end
  function self:resume()
    if not self.running then
      deadline = clock() + self.remaining
      self.running = true
    end
  end
  function self:reset()
    self.phase, self.completed, self.running = "focus", 0, false
    self.durations, self.cycles = durations, opts.cycles
    self.remaining = durations.focus
  end
  function self:snapshot()
    return {
      phase = self.phase,
      remaining = self.remaining,
      completed = self.completed,
      durations = self.durations,
      cycles = self.cycles,
    }
  end
  return self
end
return M
