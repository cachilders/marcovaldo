local Plan = include('lib/map/plan')
local RadiationSymbol = include('lib/map/symbols/radiation_symbol')
local EphemeralSymbol = include('lib/map/symbols/ephemeral_symbol')

local RadiationPlan = {
  sources = {{2, 1, 1}, {1, 7, 1}, {8, 2, 1}, {7, 8, 1}}
}

function RadiationPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function RadiationPlan:init()
  self.features, self.phenomena = self:_gesso()
  self:_init_sources()
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
  local bpm = 60 / params:get('clock_tempo')
  local function tic_radius(i)
    return util.wrap(i + 1, 1, 9)
  end

  for i = 1, #self.sources do
    local x = self.sources[i][1]
    local y = self.sources[i][2]
    local r = self.sources[i][3]
    local phenomena = {}

    if self.features[y][x]:get('active') then
      phenomena = midpoint_circle(x, y, r)
      self.sources[i][3] = tic_radius(r)
  
      for _, coords in ipairs(phenomena) do
        local x = coords[1]
        local y = coords[2]
  
        if x > 0 and y > 0 and x < PANE_EDGE_LENGTH + 1 and y < PANE_EDGE_LENGTH + 1 then
          local phenomenon = EphemeralSymbol:new({
            active = false,
            led = self.led,
            lumen = 3 * i,
            x = x,
            x_offset = self.x_offset,
            y = y,
            y_offset = self.y_offset
          })
    
          self.phenomena[y][x] = phenomenon
    
          clock.run(function()
            clock.sleep(bpm)
            self:_nullify_phenomenon(phenomenon)
          end)
        end
      end
    end
  end
  self:_step_all_symbols()
end

function RadiationPlan:_toggle_active(x, y)
  self.features[y][x]:set('active', not self.features[y][x]:get('active'))
end

function RadiationPlan:_move(x, y, radiation_symbol, clear_held_keys)
  local last_x = radiation_symbol:get('x')
  local last_y = radiation_symbol:get('y')
  radiation_symbol:set('x', x)
  radiation_symbol:set('y', y)
  for i = 1, #self.sources do
    local source = self.sources[i]
    if source[1] == last_x and source[2] == last_y then
      source[1] = x
      source[2] = y
      break
    end
  end
  clear_held_keys(.5)
  self.features[last_y][last_x] = nil
  self.features[y][x] = radiation_symbol
end

function RadiationPlan:_init_sources()
  for i = 1, #self.sources do
    local x = self.sources[i][1]
    local y = self.sources[i][2]
    self.features[y][x] = RadiationSymbol:new({
      led = self.led,
      x = x,
      x_offset = self.x_offset,
      y = y,
      y_offset = self.y_offset
    })
  end
end

function RadiationPlan:_move_source()
end

return RadiationPlan
