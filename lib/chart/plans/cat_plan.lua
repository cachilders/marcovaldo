local actions = include('lib/actions')
local CatSymbol = include('lib/chart/symbols/cat_symbol')
local EphemeralSymbol = include('lib/chart/symbols/ephemeral_symbol')
local Plan = include('lib/chart/plan')

local CatPlan = {}

function CatPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CatPlan:_add(x, y)
  local act = function(x, y, flavor)
    local phenomenon = EphemeralSymbol:new({
      led = self.led,
      source_type = 'cat',
      x = x,
      x_offset = self.x_offset,
      y = y,
      y_offset = self.y_offset
    })

    self.phenomena[x][y] = phenomenon
    self.affect_ensemble(actions.apply_effect, flavor, {x, y})

    clock.run(function()
      clock.sleep(self._get_bpm())
      self:_nullify_phenomenon(phenomenon)
    end)
  end

  local symbol = {
    act = act,
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