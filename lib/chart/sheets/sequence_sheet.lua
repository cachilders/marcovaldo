local actions = include('lib/actions')
local halt_keys = false
local key_timer = {}
local Sheet = include('lib/chart/sheet')

local SequenceSheet = {}

function SequenceSheet:new(options)
  local instance = Sheet:new(options or {})
  setmetatable(self, {__index = Sheet})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function SequenceSheet:press(x, y, z)
  default_mode_timeout_extend()
  if self.source and self.values then
    local step_count = self.values[1][1]
    local adjusted_y = y + self.y_offset
    local step = (adjusted_y - 1) * self.width + x
    if z == 0 then
      if not halt_keys then
        if key_timer[step] then
          clock.cancel(key_timer[step])
        end
        if shift_depressed or step > step_count then
          local new_length = step
          self.affect_arrangement(actions.set_sequence_length, self.source, {length = new_length})
        else
          self.affect_arrangement(actions.toggle_pulse_override, self.source, {step = step})
        end
      else
        halt_keys = false
        set_current_mode(SEQUENCE)
      end
    else
      key_timer[step] = clock.run(function()
        clock.sleep(1)
        halt_keys = true
        self.affect_arrangement(actions.trigger_step_edit, self.source, {step = step})
      end)
    end
  end
end

function SequenceSheet:refresh()
  if not self.source or not self.values then
    return
  end
  
  local current_step = current_steps()[self.source]
  local pulse_positions = self.values[1][2] 
  local step_count = self.values[1][1]
  
  -- Only refresh visible portion based on y_offset
  for c = 1, self.width do
    for r = 1, PANE_EDGE_LENGTH do  -- Only show 8 rows at a time
      local adjusted_y = r + self.y_offset
      if adjusted_y <= self.height then
        local step = (adjusted_y - 1) * self.width + c
        local step_value = pulse_positions[step]
        if step <= step_count then
          if step == current_step then
            self.led(c, r, 15)
          elseif step_value == 1 then
            self.led(c, r, 12)
          else
            self.led(c, r, 4)
          end
        else
          self.led(c, r, 0)
        end
      end
    end
  end
end

function SequenceSheet:update(index, values)
  self.source = index
  self.values = values
  self:refresh()
end

return SequenceSheet
