local Rings = {
  context = nil,
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
  for _, ring in pairs(self.rings) do
    ring:set('host', self.host)
  end
end

function Rings:get(k)
  return self[k]
end

function Rings:set(k, v)
  self[k] = v
end

function Rings:add(ring)
  table.insert(self.rings, ring)
end

function Rings:refresh()
  if self:_dirty() then
    self.host:all(0)
    for _, ring in pairs(self.rings) do
      ring:paint(self.host)
    end
    self.host:refresh()
  end
end

function Rings:pulse_ring(sequencer)
  self.rings[sequencer]:pulse()
end

function Rings:step()
  for i = 1, #self.rings do
    self.rings[i]:update()
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
