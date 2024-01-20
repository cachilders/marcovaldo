local Symbol = include('lib/symbol')

local Plan = {
  led = nil,
  features = nil,
  height = 8,
  keys_held = nil,
  keys_halt = false,
  width = 8,
  x_offset = 0,
  y_offset = 0
}

function Plan:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Plan:init()
  self.features = self:_gesso()
  self.keys_held = {}
end

function Plan:get(k)
  return self[k]
end

function Plan:set(k, v)
  self[k] = v
end

function Plan:refresh()
  self:_refresh_all_symbols()
end

function Plan:step()
  self:_step_all_symbols()
end

function Plan:mark(x, y, z)
  if z == 1 then
    self:_update_held_keys(x, y, z)
    self:_check_for_held_key_gestures()
  end

  if z == 0 then
    self:_update_held_keys(x, y, z)
    if not self.keys_halt then 
      if self.features[y][x] then
        self:_remove(x, y)
      elseif z == 0 then
        self:_add(x, y)
      end
    end
  end
end

function Plan:_add(x, y)
  local symbol = {
    led = self.led,
    lumen = 5,
    x = x,
    x_offset = self.x_offset,
    y = y,
    y_offset = self.y_offset,
  }
  self.features[y][x] = Symbol:new(symbol)
end

function Plan:_remove(x, y)
  self.features[y][x] = nil
end

function Plan:_gesso()
  local features = {}
  for r = 1, self.height do
    features[r] = {}
    for c = 1, self.width do
      features[r][c] = nil
    end
  end
  return features
end

function Plan:_shift_symbol(last_x, last_y, symbol)
  if symbol.x > 0 and symbol.x <= self.width and symbol.y > 0 and symbol.y <= self.height then
    if self.features[symbol.y][symbol.x] == nil then
      self.features[symbol.y][symbol.x] = symbol
      self.features[last_y][last_x] = nil
    else
      symbol:set('x', last_x)
      symbol:set('y', last_y)
    end
  else
    self.features[last_y][last_x] = nil
  end
end

function Plan:_update_held_keys(x, y, z)
  -- This will need to change if we deviate from 64 key plans
  -- So, you know, if a bug pops up...
  if z == 1 then
    table.insert(self.keys_held, x..y)
  else
    local next_keys = {}
    for i = 1, #self.keys_held do
      if self.keys_held[i] ~= x..y then
        table.insert(next_keys, self.keys_held[i])
      end
    end
    self.keys_held = next_keys
  end
end

function Plan:_check_for_held_key_gestures()
  if tab.contains(self.keys_held, '17') and tab.contains(self.keys_held, '18') and tab.contains(self.keys_held, '28') then
    -- Bottom left corner of panel is reset gesture
    self:_gesture_reset_plan()
  end
end

function Plan:_gesture_reset_plan()
  self:init()
  self:_sleep_grid_input()
end

function Plan:_sleep_grid_input(s)
  self.keys_halt = true
  clock.run(function() 
    clock.sleep(s or .4)
    self.keys_halt = false 
  end)
end

function Plan:_refresh_all_symbols()
  for r = 1, self.height do
    for c = 1, self.width do
      local symbol = self.features[r][c]
      if symbol then
        symbol:refresh()
      end
    end
  end
end

function Plan:_step_all_symbols()
  for r = 1, self.height do
    for c = 1, self.width do
      local symbol = self.features[r][c]
      if symbol then
        symbol:step()
      end
    end
  end
end

return Plan
