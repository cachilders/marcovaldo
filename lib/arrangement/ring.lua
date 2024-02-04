local LEDS = 64

local Ring = {
  context = nil,
  dirty = true,
  host = nil,
  id = 1,
  lumen = 10
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

function Ring:set(k, v)
  self[k] = v
  self.dirty = true
end

function Ring:get(k)
  return self[k]
end

function Ring:paint()
  -- This will expand with context once we get it working again
  if get_current_mode() == DEFAULT then
    local x = self.context:get('current_step')
    local range = self.context:get('step_count')
    self:_paint_segment(x, range)
  end

  self:set('dirty', false)
end

function Ring:_paint_segment(x, range)
  local a, b = self._extents_in_radians(x, range)
  self.host:segment(self.id, a, b, self.lumen)
end

function Ring:_paint_list_as_segments(list)
  local range = #list
  for i = 1, range do
    if list[i] then
      self:_paint_segment(i, range)
    end
  end
end

function Ring:pulse()
  local a, b = self._extents_in_radians(1, 1)
  self.host:segment(self.id, 0, 6.283185, self.lumen)
  self.host:refresh()
  self.dirty = false
end

return Ring
