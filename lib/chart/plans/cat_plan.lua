local actions = include('lib/actions')
local CatSymbol = include('lib/chart/symbols/cat_symbol')
local EphemeralSymbol = include('lib/chart/symbols/ephemeral_symbol')
local Plan = include('lib/chart/plan')

local CatPlan = {
  breeds = {
    { name = "pounce", effect = 1 },
    { name = "scratch", effect = 2 },
    { name = "purr", effect = 3 },
    { name = "meow", effect = 4 }
  }
}

function CatPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CatPlan:_add(x, y)
  local max_sequences = 4
  if params:get('marco_wrong_stop') == 2 then
    max_sequences = 5
  end
  
  local sequence = math.random(1, max_sequences)
  local breed = math.random(1, 4)
  
  local act = function(x, y)
    local phenomenon = EphemeralSymbol:new({
      led = self.led,
      source_type = 'cat',
      x = x,
      x_offset = self.x_offset,
      y = y,
      y_offset = self.y_offset
    })
    self.phenomena[x][y] = phenomenon
    self.affect_ensemble(actions.apply_effect, sequence, {effect = breed, data = {x = x, y = y}})
    clock.run(function()
      clock.sleep(self._get_bpm())
      self:_nullify_phenomenon(phenomenon)
    end)
  end
  local symbol = {
    act = act,
    breed = breed,
    led = self.led,
    lumen = 5,
    x = x,
    x_offset = self.x_offset,
    y = y,
    y_offset = self.y_offset,
    shift = function(x, y, to_x, to_y) self:_shift_symbol(x, y, to_x, to_y) end
  }
  self.features[x][y] = CatSymbol:new(symbol)
end

return CatPlan
