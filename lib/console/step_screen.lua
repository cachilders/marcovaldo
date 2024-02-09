local Screen = include('lib/console/screen')

local FIELD_LABELS = {'Note', 'Active', 'Strength', 'Width'}
local PULSES = 'Pulses'

local StepScreen = {}

function StepScreen:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Screen})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function StepScreen:draw()
end

return StepScreen