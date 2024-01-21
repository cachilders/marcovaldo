local Plan = include('lib/plan')
local ReliefSymbol = include('lib/relief_symbol')

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

return ReliefPlan
