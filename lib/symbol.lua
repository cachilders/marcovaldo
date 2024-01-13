local Symbol = {
  led = nil,
  lumen = 5,
  x = 1,
  x_offset = 0,
  y = 1,
  y_offset = 0
}

function Symbol:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Symbol:update()
  -- move, flicker, fade out, whatever...then
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.lumen)
end

return Symbol
