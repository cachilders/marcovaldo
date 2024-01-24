local Plan = include('lib/map/plan')
local RadiationSymbol = include('lib/map/symbols/radiation_symbol')

local RadiationPlan = {}

function RadiationPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

-- function RadiationPlan:mark(x, y, z, keys_held)
--   if z == 1 then
--     print('Marking radiation', x, y)
--   end
-- end

return RadiationPlan