local Symbol = include('lib/symbol')

ACTIVE_ADJ = 5

local PathSymbol = {
  active = false,
  next = nil,
  prev = nil
}
PathSymbol.__index = PathSymbol

function PathSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(PathSymbol, {__index = Symbol})
  setmetatable(instance, PathSymbol)
  return instance
end

function PathSymbol:refresh()
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.active and self.lumen + ACTIVE_ADJ or self.lumen)
end

return PathSymbol
