local Plan = include('lib/plan')
local RadiationSymbol = include('lib/symbols/radiation_symbol')

local RadiationPlan = {}

function RadiationPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

return RadiationPlan