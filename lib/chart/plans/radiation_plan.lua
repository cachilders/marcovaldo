local actions = include('lib/actions')
local Plan = include('lib/chart/plan')
local RadiationSymbol = include('lib/chart/symbols/radiation_symbol')
local EphemeralSymbol = include('lib/chart/symbols/ephemeral_symbol')

local MAX_AMP = 127
local MAX_RAD = 8
local PULSE_RADIUS_OPERAND = MAX_RAD / MAX_AMP

local RadiationPlan = {
  emitters = {{1, 1}, {1, 8}, {8, 1}, {8, 8}}
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
  self.affect_ensemble(actions.set_source_positions, nil, self.emitters)
end

function RadiationPlan:mark(x, y, z, keys_held, clear_held_keys)
  if z == 0 then
    if #keys_held == 0 and self.features[x][y] then
      self:_toggle_active(x, y)
    elseif #keys_held == 1 and not self.features[x][y] then
      self:_move(x, y, self:_symbol_from_held_key(keys_held[1]), clear_held_keys)
    end
  end
end

function RadiationPlan:step()
  self:_place_emitters()
  self:_step_all_symbols()
end

function RadiationPlan:emit_pulse(i, v, s)  
  local x = self.emitters[i][1]
  local y = self.emitters[i][2]

  if self.features[x][y]:get('active') then
    self:_spawn_wave(x, y, v, s)
  end
end

function RadiationPlan:_spawn_wave(x, y, velocity, envelope_time)
  -- TODO: a, d, s, r timing defines diffusion characteristics
  -- Push more behavior down to the symbol and reconsider the
  -- Nature of phenomena belonging to plans.
  clock.run(function ()
    local i = 1
    local radius = math.floor(PULSE_RADIUS_OPERAND * (velocity or 100))
    local step_duration = (envelope_time or .5) / radius
    local phenomena = nil

    while i <= radius do    
      phenomena = midpoint_circle(x, y, i)
      local lumen = radius * 2 - i * 2 + 2
      for _, coords in ipairs(phenomena) do
        self:_spawn_wave_particle(coords[1], coords[2], lumen, step_duration)
      end
      i = i + 1
      clock.sleep(step_duration)
    end
  end)
end

function RadiationPlan:_spawn_wave_particle(x, y, lumen, lifespan)
  if x > 0 and y > 0 and x < PANE_EDGE_LENGTH + 1 and y < PANE_EDGE_LENGTH + 1 then
    local phenomenon = EphemeralSymbol:new({
      active = false,
      led = self.led,
      lumen = lumen,
      source_type = 'radiation',
      x = x,
      x_offset = self.x_offset,
      y = y,
      y_offset = self.y_offset
    })

    self.phenomena[x][y] = phenomenon

    clock.run(function()
      clock.sleep(lifespan)
      self:_nullify_phenomenon(phenomenon)
    end)
  end
end

function RadiationPlan:_toggle_active(x, y)
  local symbol = self.features[x][y]
  symbol:set('active', not symbol:get('active'))
  self.affect_ensemble(actions.toggle_sequence, symbol:get('id'))
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
    self.features[x][y] = radiation_symbol
    self.affect_ensemble(actions.set_source_positions, nil, self.emitters)
  end
end

function RadiationPlan:_place_emitters()
  for i = 1, #self.emitters do
    local x = self.emitters[i][1]
    local y = self.emitters[i][2]
    if not self.features[x][y] then
      self.features[x][y] = RadiationSymbol:new({
        id = i,
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