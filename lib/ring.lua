local LEDS = 64

local Ring = {
  dirty = true,
  id = 1,
  lumen = 10,
  range = LEDS,
  throttled = false,
  x = 1
}

function Ring._extents_in_radians(i, range)
  local segment_radians = (math.pi / range) * 2
  local start = i == 1 and 0 or (i - 1) * segment_radians
  return start, i * segment_radians
end

function Ring:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Ring:change(delta)
  if not self.throttled then
    self:set('x', util.wrap(self.x + delta, 1, self.range))
    self.dirty = true
    self.throttled = true
    clock.run(function()
      clock.sleep((LEDS/self.range) * .01)
      self.throttled = false
    end)
  end
end

function Ring:set(k, v)
  self[k] = v
end

function Ring:get(k)
  return self[k]
end

function Ring:paint(host)
  if self.range == LEDS then
    host:led(self.id, self.x, self.lumen)
  else
    local a, b = self._extents_in_radians(self.x, self.range)
    host:segment(self.id, a, b, self.lumen)
  end
end

return Ring
