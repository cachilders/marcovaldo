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

function SequenceSheet:coords_to_step(x, y)
  if self.is_64_key then
    local step_offset = self:get('step_offset') or 0
    return (y - 1) * PANE_EDGE_LENGTH + x + step_offset
  else
    return (y - 1) * 16 + x
  end
end

function SequenceSheet:press(x, y, z)
  default_mode_timeout_extend()
  
  if self.source and self.values then
    local step_count = self.values[1][1]
    local step_offset = self:get('step_offset') or 0
    
    local step
    if self.is_64_key then
      step = (y - 1) * PANE_EDGE_LENGTH + x + step_offset
    else
      step = self:coords_to_step(x, y)
    end
    
    if step > 128 then return end
    
    if z == 0 then
      if not halt_keys then
        if key_timer[step] then
          clock.cancel(key_timer[step])
        end
        if shift_depressed then
          local new_length = step
          self.affect_arrangement(actions.set_sequence_length, self.source, {length = new_length})
        elseif step <= step_count then
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
  local step_offset = self:get('step_offset') or 0
  
  if self.is_64_key then
    -- For 64-key grid, map 8x8 to steps
    for c = 1, PANE_EDGE_LENGTH do
      for r = 1, PANE_EDGE_LENGTH do
        local step = (r - 1) * PANE_EDGE_LENGTH + c + step_offset
        
        if step <= step_count then
          local step_value = pulse_positions[step]
          if step == current_step then
            self.led(c, r, 15)
          elseif step_value > 0 then
            self.led(c, r, 12)
          else
            self.led(c, r, 4)
          end
        else
          self.led(c, r, 0)
        end
      end
    end
  else
    -- For 128-key grid, use full width
    for c = 1, 16 do
      for r = 1, PANE_EDGE_LENGTH do
        local step = self:coords_to_step(c, r)
        
        if step <= step_count then
          local step_value = pulse_positions[step]
          if step == current_step then
            self.led(c, r, 15)
          elseif step_value > 0 then
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

function SequenceSheet:on_gesture_complete()
  for step, timer in pairs(key_timer) do
    if timer then
      clock.cancel(timer)
      key_timer[step] = nil
    end
  end
  halt_keys = true
end

return SequenceSheet
