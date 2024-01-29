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

function Symbol:get(k)
  return self[k]
end

function Symbol:set(k, v)
  self[k] = v
end

function Symbol:refresh()
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.lumen)
end

function Symbol:step()
  -- move, flicker, fade out, whatever
end

return Symbol
