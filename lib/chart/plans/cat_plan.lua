local Plan = include('lib/chart/plan')
local CatSymbol = include('lib/chart/symbols/cat_symbol')
local EphemeralSymbol = include('lib/chart/symbols/ephemeral_symbol')

local CatPlan = {
  affect_ensemble = nil
}

function CatPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CatPlan:_add(x, y)
  local act = function(x, y)
      -- Purr, Meow, Hiss, Mewl, Yowl, Scratch, Jump ¯\_(ツ)_/¯
    local phenomenon = EphemeralSymbol:new({
      led = self.led,
      source_type = 'cat',
      x = x,
      x_offset = self.x_offset,
      y = y,
      y_offset = self.y_offset
    })

    self.phenomena[y][x] = phenomenon

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
  self.features[y][x] = CatSymbol:new(symbol)
end

return CatPlan