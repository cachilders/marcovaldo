local Plan = include('lib/symbol')

local CatSymbol = {}

setmetatable(CatSymbol, { __index.Symbol })

function CatSymbol:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Symbol:update()
  -- The cat has a random chance of moving or sitting still with
  -- a potentially randomfrequency of opportunities
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.lumen)
end

return CatSymbol