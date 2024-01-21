local Plan = include('lib/plan')
local ReliefSymbol = include('lib/symbols/relief_symbol')

local ReliefPlan = {
  -- Stitches all the other plans together
  -- Receives other plan features as input?
}

function ReliefPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

-- function ReliefPlan:mark(x, y, z, keys_held)
--   if z == 1 then
--     print('Marking relief', x, y)
--   end
-- end

return ReliefPlan
