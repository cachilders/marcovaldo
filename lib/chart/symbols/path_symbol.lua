local Symbol = include('lib/chart/symbol')

ACTIVE_ADJ = 5

local PathSymbol = {
  active = false,
  next = nil,
  prev = nil
}

function PathSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function PathSymbol:refresh()
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.active and self.lumen + ACTIVE_ADJ or self.lumen)
end

return PathSymbol
