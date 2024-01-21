local Symbol = include('lib/symbol')

local PathStepSymbol = {}

function PathStepSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

return PathStepSymbol
