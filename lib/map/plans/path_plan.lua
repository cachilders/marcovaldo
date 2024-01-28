local Plan = include('lib/map/plan')
local PathSymbol = include('lib/map/symbols/path_symbol')
local EphemeralSymbol = include('lib/map/symbols/ephemeral_symbol')

local PathPlan = {
  head = nil,
  steps_to_active = {},
  step_symbol = nil,
  tail = nil
}

function PathPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function PathPlan:init()
  self.features, self.phenomena = self._gesso()
  self.head = nil
  self.tail = nil
  self.steps_to_active = {}
  self.step_symbol = nil
end

function PathPlan:mark(x, y, z, keys_held, clear_held_keys)
  if z == 0 then
    if #keys_held == 0 and self.features[y][x] then
      self:_remove(x, y)
    elseif #keys_held == 0 then
      self:_add(x, y)
    elseif #keys_held == 1 and not self.features[y][x] then
      self:_add(x, y, self:_symbol_from_held_key(keys_held[1]), clear_held_keys)
    end
  end
end

function PathPlan:refresh()
  self:_refresh_all_symbols()
end

function PathPlan:step(count)
  if count == 1 then
    if #self.steps_to_active > 0 then
      self:_step_toward_active()
    else
      self.step_symbol = nil
      self:_set_next_active_symbol()
    end
  end
end

function PathPlan:_set_next_active_symbol()
  local active_symbol = nil
  local current_symbol = self.head
  local next_active_symbol = nil

  while self.head and not active_symbol do
    if current_symbol:get('active') then
      active_symbol = current_symbol
    elseif current_symbol:get('next') then
      current_symbol = current_symbol:get('next') 
    else
      current_symbol = self.head
    end
  end

  if active_symbol and self.head then
    if active_symbol:get('next') then
      next_active_symbol = active_symbol:get('next')
    else
      next_active_symbol = self.head
    end

    current_symbol:set('active', false)
    next_active_symbol:set('active', true)

    if self.head ~= self.tail then
      local x1 = active_symbol:get('x')
      local y1 =  active_symbol:get('y')
      local x2 = next_active_symbol:get('x')
      local y2 = next_active_symbol:get('y')
      self.steps_to_active = b_line(x1,y1, x2, y2)
    end
  end
end

function PathPlan:_step_toward_active()
  local last_phenomenon = self.step_symbol
  local step_coord = table.remove(self.steps_to_active, 1)

  self.step_symbol = EphemeralSymbol:new({
    led = self.led,
    source_type = 'path',
    x = step_coord[1],
    x_offset = self.x_offset,
    y = step_coord[2],
    y_offset = self.y_offset,
    lumen = 3
  })
  
  self.phenomena[step_coord[2]][step_coord[1]] = self.step_symbol

  if last_phenomenon then
    clock.run(function()
      clock.sleep(.1)
      self:_nullify_phenomenon(last_phenomenon)
    end)
  end
end

function PathPlan:_add(x, y, insert_from_symbol, clear_held_keys)
  local symbol = PathSymbol:new({
    active = false,
    led = self.led,
    x = x,
    x_offset = self.x_offset,
    y = y,
    y_offset = self.y_offset
  })

  if not insert_from_symbol then
    if not self.head then
      symbol:set('active', true)
      self.head = symbol
      self.tail = symbol
    else
      self.tail:set('next', symbol)
      symbol:set('prev', self.tail)
      self.tail = symbol
    end
  else
    if not insert_from_symbol:get('next') then
      insert_from_symbol:set('next', symbol)
      symbol:set('prev', self.tail)
      self.tail = symbol
    elseif insert_from_symbol and symbol:get('x') == self.head.x and symbol:get('y') == self.head.y then
      symbol = self.head
    else
      symbol:set('prev', insert_from_symbol)
      symbol:set('next', insert_from_symbol:get('next'))
      insert_from_symbol:get('next'):set('prev', symbol)
      insert_from_symbol:set('next', symbol)
    end
    clear_held_keys(.75)
  end
  self.features[y][x] = symbol
end

function PathPlan:_remove(x, y)
  local symbol_to_remove = self.features[y][x]

  if not symbol_to_remove:get('prev') and not symbol_to_remove:get('next') then
    self.head = nil
    self.tail = nil
  elseif symbol_to_remove:get('prev') and not symbol_to_remove:get('next') then
    symbol_to_remove:get('prev'):set('next', nil)
    self.tail = symbol_to_remove:get('prev')

    if symbol_to_remove:get('active') then
      self.head:set('active', true)
      self:_reset_path()
    end
  elseif not symbol_to_remove:get('prev') and symbol_to_remove:get('next') then
    symbol_to_remove:get('next'):set('prev', nil)
    self.head = symbol_to_remove:get('next')
    
    if symbol_to_remove:get('active') then
      self.head:set('active', true)
      self:_reset_path()
    end
  else
    symbol_to_remove:get('next'):set('prev', symbol_to_remove:get('prev'))
    symbol_to_remove:get('prev'):set('next', symbol_to_remove:get('next'))
    
    if symbol_to_remove:get('active') then
      symbol_to_remove:get('next'):set('active', true)
      self:_reset_path()
    end
  end

  self.features[y][x] = nil
end

function PathPlan:_reset_path()
  self.active_symbol = nil
  self.steps_to_active = {}
  self.phenomena = self._pentimento(self.phenomena)
end

return PathPlan
