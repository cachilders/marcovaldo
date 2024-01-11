local LEDS = 64

local Rings = {
  host = nil,
  rings = {}
}

local function _extents(i, range)
  local segment_width = math.floor(LEDS/range)
  local start = i * segment_width
  return start, start + segment_width
end

function Rings:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Rings:init(n)
  self.host = arc.connect(n)
end

function Rings:add(ring)
  table.insert(self.rings, ring)
end

function Rings:paint()
  if self:_dirty() then
    for i, ring in pairs(self.rings) do
      if ring:get('range') == LEDS then
        self.host:led(ring:get('id'), ring:get('x'), ring:get('lumen'))
      else
        local a, b = _extents(ring:get('x'), ring:get('range'))
        self.host:segment(self:get('id'), a, b, ring:get('lumen'))
      end
      ring:set('dirty', false)
    end
    self.host:redraw()
  end
end

function Rings:_dirty()
  local dirty = false
  for i, ring in pairs(self.rings) do
      dirty = ring:get('dirty') or dirty
  end
end

return Rings
