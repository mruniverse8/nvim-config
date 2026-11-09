local M = {}
function M.new(opts)
  local music = require("petsadhd.audio").new(vim.tbl_extend("force", opts.music, { enabled = true }))
  local self = { music = opts.music.enabled, alerts = opts.alerts.enabled, controller = music }
  function self:update(timer)
    if self.music and timer.running and timer.phase == "focus" then
      music:pause(false)
      -- Only explicit toggles retry unavailable streams, never every UI tick.
      if music.status ~= "unavailable" then
        music:start()
      end
    else
      music:pause(true)
    end
  end
  function self:toggle()
    self.music = not self.music
    if not self.music then
      music:stop()
    else
      music.status = "off"
    end
  end
  function self:alert()
    if not self.alerts then
      return
    end
    if self.alert_job then
      pcall(vim.fn.jobstop, self.alert_job)
    end
    if vim.fn.executable("ffplay") == 0 then
      if not self.warned then
        vim.notify("Pomodoro alerts need ffplay", vim.log.levels.WARN)
        self.warned = true
      end
      return
    end
    self.alert_job = vim.fn.jobstart({
      "ffplay",
      "-nodisp",
      "-autoexit",
      "-loglevel",
      "error",
      "-volume",
      tostring(opts.alerts.volume),
      "-f",
      "lavfi",
      "sine=frequency=880:duration=0.35",
    }, {
      on_exit = function(_, code)
        if code ~= 0 and code ~= 143 and not self.warned and not self.closed then
          self.warned = true
          vim.schedule(function()
            vim.notify("Pomodoro: alert audio failed; check audio output", vim.log.levels.WARN)
          end)
        end
      end,
    })
  end
  function self:close()
    self.closed = true
    music:stop()
    if self.alert_job then
      pcall(vim.fn.jobstop, self.alert_job)
    end
  end
  return self
end
return M
