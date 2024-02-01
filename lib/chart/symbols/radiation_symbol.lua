local Symbol = include('lib/chart/symbol')

local RadiationSymbol = {
  active = true,
  id = 1
}

function RadiationSymbol:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

return RadiationSymbol
