local Symbol = include('lib/map/symbol')

local ReliefSymbol = {}

function ReliefSymbol:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

return ReliefSymbol
