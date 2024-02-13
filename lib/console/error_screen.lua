local console_constants = include('lib/console/constants')
local Screen = include('lib/console/screen')

local ERRORS = {
  'Please connect a grid'
}
local X_RULE = console_constants.SCREEN_WIDTH / 2
local Y_RULE = console_constants.SCREEN_HEIGHT / 2

local ErrorScreen = {
  error_index = 0
}

function ErrorScreen:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Screen})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ErrorScreen:draw()
  screen.move(X_RULE, Y_RULE)
  screen.text_center(ERRORS[self.error_index])
end

function ErrorScreen:update(i)
  self.error_index = i
end

return ErrorScreen