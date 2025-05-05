local actions = include('lib/actions')
local halt_keys = false
local key_timer = {}
local keys_held = {}
local Sheet = include('lib/chart/sheet')

local SequenceSheet = {}

function SequenceSheet:new(options)
  local instance = Sheet:new(options or {})
  setmetatable(self, {__index = Sheet})
  setmetatable(instance, self)
  self.__index = self
  self.is_64_key = options.is_64_key or false
  return instance
end

function SequenceSheet:press(x, y, z)
  default_mode_timeout_extend()
  
  -- Handle page turn gesture for 64-key grid
  if self.is_64_key and z == 1 then
    table.insert(keys_held, x..y)
    if tab.contains(keys_held, '87') and tab.contains(keys_held, '88') and tab.contains(keys_held, '78') then
      -- Bottom right corner is page flip gesture
      self.page = self.page % 2 + 1
      self:set('step_offset', (self.page - 1) * 64)  -- 64 steps per page
      keys_held = {}
      return
    end
  elseif z == 0 then
    -- Clear held keys on release
    local next_keys = {}
    for i = 1, #keys_held do
      if keys_held[i] ~= x..y then
        table.insert(next_keys, keys_held[i])
      end
    end
    keys_held = next_keys
  end
  
  if self.source and self.values then
    local step_count = self.values[1][1]
    local step_offset = self:get('step_offset') or 0
    
    -- For 64-key grid, map coordinates to steps
    local step
    if self.is_64_key then
      step = (y - 1) * PANE_EDGE_LENGTH + x + step_offset
    else
      step = self:coords_to_step(x, y)
    end
    
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
  else
    -- For 128-key grid, use full width
    for c = 1, self.width do
      for r = 1, PANE_EDGE_LENGTH do
        local step = self:coords_to_step(c, r)
        
        if step <= step_count then
          local step_value = pulse_positions[step]
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
