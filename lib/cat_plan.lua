local Plan = include('lib/plan')
local CatSymbol = include('lib/cat_symbol')

local CatPlan = {}

setmetatable(CatPlan, { __index = Plan })

function CatPlan:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CatPlan:_add(x, y)
  local symbol = {
    led = self.led,
    lumen = 5,
    x = x,
    x_offset = self.x_offset,
    shift = function(x, y, to_x, to_y) print('Shift symbol at '..x, y..' to '..to_x, to_y) end, -- callback to move within the plan features
  }
  self.features[y][x] = Symbol:new(symbol)
end

return CatPlan