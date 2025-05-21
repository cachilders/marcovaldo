local Pane = include('lib/chart/pane')

local keys_held = {}
local gesture_keys_to_halt = {}

local SheetPane = {
  sheet = nil,
  page = 1,
  total_pages = 2,  -- For 64-key grid
  steps_per_page = 64,
}

function SheetPane:new(options)
  local instance = Pane:new(options)
  setmetatable(self, {__index = Pane})
  setmetatable(instance, self)
  self.__index = self
  self.is_64_key = options.is_64_key or false
  return instance
end

function SheetPane:init(led)
  self.sheet:set('led', led)
  self:_update_offsets()
end

function SheetPane:_update_offsets()
  if self.is_64_key then
    local step_offset = (self.page - 1) * self.steps_per_page
    self.sheet:set('step_offset', step_offset)
  else
    self.sheet:set('step_offset', 0)
  end
end

function SheetPane:get_offsets()
  return 0, 0
end

function SheetPane:_update_held_keys(x, y, z)
  if z == 1 then
    table.insert(keys_held, x..y)
  else
    local next_keys = {}
    for i = 1, #keys_held do
      if keys_held[i] ~= x..y then
        table.insert(next_keys, keys_held[i])
      end
    end
    keys_held = next_keys
  end
end

function SheetPane:_check_for_held_key_gestures()
  if tab.contains(keys_held, '88') and tab.contains(keys_held, '78') and tab.contains(keys_held, '87') then
    self.page = self.page % 2 + 1
    self:_update_offsets()
    
    gesture_keys_to_halt = {'88', '78', '87'}
    
    for _, key in ipairs(gesture_keys_to_halt) do
      if self.sheet.key_timer and self.sheet.key_timer[key] then
        clock.cancel(self.sheet.key_timer[key])
        self.sheet.key_timer[key] = nil
      end
    end
    
    keys_held = {}

    if self.sheet.on_gesture_complete then
      self.sheet:on_gesture_complete()
    end

    return true
  end
  return false
end

function SheetPane:_coords_to_step(x, y)
  if self.is_64_key then
    local step_offset = self.sheet:get('step_offset') or 0
    return (y - 1) * PANE_EDGE_LENGTH + x + step_offset
  else
    return self.sheet:coords_to_step(x, y)
  end
end

function SheetPane:_step_to_coords(step)
  if self.is_64_key then
    local step_offset = self.sheet:get('step_offset') or 0
    local adjusted_step = step - step_offset
    local y = math.floor((adjusted_step - 1) / PANE_EDGE_LENGTH) + 1
    local x = ((adjusted_step - 1) % PANE_EDGE_LENGTH) + 1
    return x, y
  else
    return self.sheet:step_to_coords(step)
  end
end

function SheetPane:_is_gesture_key(x, y)
  local key = x..y
  return key == '88' or key == '78' or key == '87'
end

function SheetPane:pass(x, y, z)
  local key = x..y
  
  if tab.contains(gesture_keys_to_halt, key) then
    if self.sheet.key_timer and self.sheet.key_timer[key] then
      clock.cancel(self.sheet.key_timer[key])
      self.sheet.key_timer[key] = nil
    end
    
    local next_keys = {}
    for i = 1, #gesture_keys_to_halt do
      if gesture_keys_to_halt[i] ~= key then
        table.insert(next_keys, gesture_keys_to_halt[i])
      end
    end
    gesture_keys_to_halt = next_keys

    if #gesture_keys_to_halt == 0 and z == 0 then
      self.sheet:press(x, y, z)
    end
    return
  end

  if #gesture_keys_to_halt > 0 then
    return
  end

  self:_update_held_keys(x, y, z)

  if z == 1 and self:_check_for_held_key_gestures() then
    return
  end

  self.sheet:press(x, y, z)
end

function SheetPane:refresh()
  self.sheet:refresh()
end

return SheetPane 