local constants = include('lib/constants')
local LEDS = 64
local MAX_RADIANS = 6.28 

local Ring = {
  context = nil,
  dirty = true,
  host = nil,
  id = 1,
  lumen = 10
}

function Ring._extents_in_radians(i, range)
  i = i or 0
  local segment_radians = MAX_RADIANS / range
  local start = i == 1 and 0 or (i - 1) * segment_radians
  return start, i * segment_radians
end

function Ring._percent_in_radians(i, range)
  i = i or 0
  i = i == 1 and 0 or i - 1
  return util.clamp((MAX_RADIANS / range) * i, 0, MAX_RADIANS)
end

function Ring:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Ring:set(k, v)
  self[k] = v
end

function Ring:get(k)
  return self[k]
end

function Ring:paint_step()
  if get_current_mode() == DEFAULT then
    local x = self.context:get('current_step')
    local range = self.context:get('step_count')
    self:_paint_segment(x, range)
  end

  self.dirty = false
end

function Ring:paint_value(value, range, value_type)
  if value_type == constants.ARRANGEMENT.TYPES.BOOL then
    self:_paint_bool(value)
  elseif value_type == constants.ARRANGEMENT.TYPES.BOOL_LIST then
    self:_paint_list_as_segments(value)
  elseif value_type == constants.ARRANGEMENT.TYPES.POSITION then
    self:_paint_segment(value, range, true)
  elseif value_type == constants.ARRANGEMENT.TYPES.PORTION then
    self:_paint_portion(value, range)
  elseif value_type == constants.ARRANGEMENT.TYPES.POSITION then
    self:_paint_segment(value, range)
  end
  self.host:refresh()
end

function Ring:pulse()
  local a, b = self._extents_in_radians(1, 1)
  self.host:segment(self.id, 0, 6.283185, self.lumen)
  self.host:refresh()
  self.dirty = false
end

function Ring:update()
  self.dirty = true
end

function Ring:_paint_bool(value)
  if value then
    a = 4.71
  else
    a = 1.57
  end
  self.host:segment(self.id, a, a + 3.14, self.lumen)
end

function Ring:_paint_list_as_segments(list)
  -- todo. no good
  local list = {true, false, false, true, false, true, true, false}
  local range = #list
  for i = 1, range do
    if list[i] then
      self:_paint_segment(i, range)
    end
  end
end

function Ring:_paint_portion(x, range)
  local extent = self._percent_in_radians(x, range)
  self.host:segment(self.id, 0, extent, self.lumen)
end

function Ring:_paint_segment(x, range, nullable)
  local a, b = self._extents_in_radians(x, range)
  local lumen = self.lumen
  if nullable and x == 0 then
    lumen = 0
  end
  self.host:segment(self.id, a, b, lumen)
end


return Ring
