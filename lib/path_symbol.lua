local Symbol = include('lib/symbol')

local PathSymbol = {
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

function PathSymbol:update()
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.lumen)
end

return PathSymbol
