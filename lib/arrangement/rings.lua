local Rings = {
  context = nil,
  delta = nil,
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
  self.host.delta = self.delta
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
  local mode = get_current_mode()
  if self:_dirty() then
    if mode == DEFAULT then
      self.host:all(0)
      for _, ring in pairs(self.rings) do
        ring:paint_step(self.host)
      end
      self.host:refresh()
    end
  end
end

function Rings:paint_editor_state(state)
  local rings = self.rings
  local values = state[1]
  local ranges = state[2]
  local types = state[3]
  for i = 1, #rings do
    rings[i]:paint_value(values[i], ranges[i], types[i])
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