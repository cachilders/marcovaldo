local Symbol = include('lib/chart/symbol')

local Plan = {
  affect_arrangement = nil,
  affect_ensemble = nil,
  affect_console = nil,
  led = nil,
  name = '',
  features = nil,
  phenomena = nil,
  x_offset = 0,
  y_offset = 0
}

function Plan:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Plan:hydrate(plan)
  self:init()
  for c = 1, PANE_EDGE_LENGTH do
    self.features[c] = {}
    for r = 1, PANE_EDGE_LENGTH do
      local symbol = plan.features[c][r]
        if symbol then
          self:_add(symbol.x, symbol.y)
        end
    end
  end
end

function Plan:init()
  self.features, self.phenomena = self._gesso()
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

function Plan:step(count)
  if count == 1 then
    self:_step_all_symbols(count)
  end
end

function Plan:mark(x, y, z, keys_held, clear_held_keys)
  if z == 0 then
    if self.features[x][y] then
      self:_remove(x, y, clear_held_keys)
    elseif z == 0 then
      self:_add(x, y, clear_held_keys)
    end
  end
end

function Plan:reset()
  self:init()
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
  self.features[x][y] = Symbol:new(symbol)
end

function Plan:_remove(x, y)
  self.features[x][y] = nil
end

function Plan._gesso()
  -- TODO: Animate
  local features = {}
  local phenomena = {}
  for c = 1, PANE_EDGE_LENGTH do
    features[c] = {}
    phenomena[c] = {}
    for r = 1, PANE_EDGE_LENGTH do
      features[c][r] = nil
      phenomena[c][r] = nil
    end
  end
  return features, phenomena
end

function Plan._pentimento(t)
  -- The relief plan is bound to the phenomena of
  -- other plans at init. Reusing the outer object
  -- maintains that bond when clearing
  for c = 1, PANE_EDGE_LENGTH do
    t[c] = {}
    for r = 1, PANE_EDGE_LENGTH do
      t[c][r] = nil
    end
  end
  return t
end

function Plan._get_bpm()
  return 60 / params:get('clock_tempo')
end

function Plan:_nullify_phenomenon(symbol)
  if symbol then
    local x = symbol:get('x')
    local y = symbol:get('y')
    self.phenomena[x][y] = nil
  end
end

function Plan:_shift_symbol(last_x, last_y, symbol)
  if symbol.x > 0 and symbol.x <= PANE_EDGE_LENGTH and symbol.y > 0 and symbol.y <= PANE_EDGE_LENGTH then
    if self.features[symbol.x][symbol.y] == nil then
      self.features[symbol.x][symbol.y] = symbol
      self.features[last_x][last_y] = nil
    else
      symbol:set('x', last_x)
      symbol:set('y', last_y)
    end
  else
    self.features[last_x][last_y] = nil
  end
end

function Plan:_symbol_from_held_key(label)
  local x = tonumber(label:sub(1,1))
  local y = tonumber(label:sub(2,2))
  return self.features[x][y]
end

function Plan:_refresh_all_symbols()
  for c = 1, PANE_EDGE_LENGTH do
    for r = 1, PANE_EDGE_LENGTH do
      local phenomenon_symbol = self.phenomena[c][r]
      local feature_symbol = self.features[c][r]
      if phenomenon_symbol then
        phenomenon_symbol:refresh()
      end
      if feature_symbol then
        feature_symbol:refresh()
      end
    end
  end
end

function Plan:_step_all_symbols()
  for c = 1, PANE_EDGE_LENGTH do
    for r = 1, PANE_EDGE_LENGTH do
      local feature_symbol = self.features[c][r]
      local phenomenon_symbol = self.phenomena[c][r]
      if feature_symbol then
        feature_symbol:step()
      end
      if phenomenon_symbol then
        phenomenon_symbol:step()
      end
    end
  end
end

return Plan
