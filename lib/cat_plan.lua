local Plan = include('lib/plan')
local CatSymbol = include('lib/cat_symbol')

local CatPlan = {}
CatPlan.__index = CatPlan

function CatPlan:new(options)
  local instance = Plan:new(options)
  setmetatable(CatPlan, {__index = Plan})
  setmetatable(instance, CatPlan)
  return instance
end

function CatPlan:_add(x, y)
  local symbol = {
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