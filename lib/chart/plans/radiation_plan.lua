local Plan = include('lib/chart/plan')
local RadiationSymbol = include('lib/chart/symbols/radiation_symbol')
local EphemeralSymbol = include('lib/chart/symbols/ephemeral_symbol')

local RadiationPlan = {
  -- TODO: Redius should be derived from something real
  -- as should velocity of expansion
  -- and new waves should issue on every beat of
  -- related sequence
  emitters = {{2, 1, 1}, {1, 6, 1}, {8, 4, 1}, {5, 8, 1}}
}

function RadiationPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function RadiationPlan:init()
  self.features, self.phenomena = self._gesso()
end

function RadiationPlan:mark(x, y, z, keys_held, clear_held_keys)
  if z == 0 then
    if #keys_held == 0 and self.features[y][x] then
      self:_toggle_active(x, y)
    elseif #keys_held == 1 and not self.features[y][x] then
      self:_move(x, y, self:_symbol_from_held_key(keys_held[1]), clear_held_keys)
    end
  end
end

function RadiationPlan:step()
  local bpm = self._get_bpm()
  local function tick_radius(i)
    return util.wrap(i + 1, 1, 9)
  end

  self:_place_emitters()

  for i = 1, #self.emitters do
    local x = self.emitters[i][1]
    local y = self.emitters[i][2]
    local r = self.emitters[i][3]
    local phenomena = {}

    if self.features[y][x]:get('active') then
      phenomena = midpoint_circle(x, y, r)
      self.emitters[i][3] = tick_radius(r)
  
      for _, coords in ipairs(phenomena) do
        local x = coords[1]
        local y = coords[2]
  
        if x > 0 and y > 0 and x < PANE_EDGE_LENGTH + 1 and y < PANE_EDGE_LENGTH + 1 then
          local phenomenon = EphemeralSymbol:new({
            active = false,
            led = self.led,
            lumen = 3,
            source_type = 'radiation',
            x = x,
            x_offset = self.x_offset,
            y = y,
            y_offset = self.y_offset
          })

          self.phenomena[y][x] = phenomenon
    
          clock.run(function()
            -- Sort this out when we start getting real
            -- input from the arrangement
            clock.sleep(bpm/2)
            self:_nullify_phenomenon(phenomenon)
          end)
        end
      end
    end
  end
  self:_step_all_symbols()
end

function RadiationPlan:_toggle_active(x, y)
  local symbol = self.features[y][x]
  symbol:set('active', not symbol:get('active'))

  if not symbol:get('active') then
    -- reset the radius to 1
    -- Wait to worry about this until 
    -- we know 
  end
end

function RadiationPlan:_move(x, y, radiation_symbol, clear_held_keys)
  if radiation_symbol then
    local last_x = radiation_symbol:get('x')
    local last_y = radiation_symbol:get('y')
    radiation_symbol:set('x', x)
    radiation_symbol:set('y', y)
    for i = 1, #self.emitters do
      local emitter = self.emitters[i]
      if emitter[1] == last_x and emitter[2] == last_y then
        emitter[1] = x
        emitter[2] = y
        break
      end
    end
    clear_held_keys(.5)
    self.features[last_y][last_x] = nil
    self.features[y][x] = radiation_symbol
  end
end

function RadiationPlan:_place_emitters()
  for i = 1, #self.emitters do
    local x = self.emitters[i][1]
    local y = self.emitters[i][2]
    if not self.features[y][x] then
      self.features[y][x] = RadiationSymbol:new({
        led = self.led,
        lumen = 10,
        x = x,
        x_offset = self.x_offset,
        y = y,
        y_offset = self.y_offset
      })
    end
  end
end

return RadiationPlan