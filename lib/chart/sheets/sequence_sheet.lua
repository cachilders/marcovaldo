local actions = include('lib/actions')
local Sheet = include('lib/chart/sheet')

local SequenceSheet = {}

function SequenceSheet:new(options)
  local instance = Sheet:new(options or {})
  setmetatable(self, {__index = Sheet})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function SequenceSheet:refresh()
  local current_step = current_steps()[self.source]
  local pulse_positions = self.values[1][2] 
  local step_count = self.values[1][1]
  for c = 1, self.height do
    for r = 1, self.width do
      local step = ((c-1)*self.width) + r
      local step_value = pulse_positions[step]
      if step <= step_count then
        if step == current_step then
          self.led(r, c, 15)
        elseif step_value == true then
          self.led(r, c, 12)
        else
          self.led(r, c, 4)
        end
      else
        self.led(r, c, 0)
      end
    end
  end
end

function SequenceSheet:update(index, values)
  self.source = index
  self.values = values
  self:refresh()
end

function Sheet:press(x, y, z)
  default_mode_timeout_extend()
  if self.source and self.values and z == 1 then
    local step_count = self.values[1][1]
    local step = (y - 1) * self.width + x
    if shift_depressed or step > step_count then
      local new_length = step
      self.affect_arrangement(actions.set_sequence_length, self.source, {length = new_length})
    else
      self.affect_arrangement(actions.toggle_pulse_override, self.source, {step = step})
    end
  end
end

return SequenceSheet
