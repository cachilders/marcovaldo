local actions = include('lib/actions')
local Sheet = include('lib/chart/sheet')

local StepSheet = {}

function StepSheet:new(options)
  local instance = Sheet:new(options or {})
  setmetatable(self, {__index = Sheet})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function StepSheet:refresh()
  print('refreshing step sheet')
end

return StepSheet
