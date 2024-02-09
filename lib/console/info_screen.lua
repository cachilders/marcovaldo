local constants = include('lib/constants')
local Screen = include('lib/console/screen')

local InfoScreen = {}

function InfoScreen:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Screen})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function InfoScreen:draw()
  --constants.GLYPHS.BANG
end

return InfoScreen