local Rings = {
  host = nil,
  rings = {}
}

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
    self.host:all(0)
    for _, ring in pairs(self.rings) do
      ring:paint(self.host)
      ring:set('dirty', false)
    end
    self.host:refresh()
  end
end

function Rings:_dirty()
  local dirty = false
  for _, ring in pairs(self.rings) do
      dirty = ring:get('dirty') or dirty
  end
  return dirty
end

return Rings
