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
  self.rings[sequencer]:pulse(self.host)
end

function Rings:step_feedback(sequencer, step_value)
  -- TEMP POC This needs to reflect the sequencer state, distinct from the input state
  -- so a more thoughtful approach is required
  self.rings[sequencer]:set('x', step_value)
end

function Rings:turn_to_ring(n, delta)
  self.rings[n]:change(delta)
end

function Rings:_dirty()
  local dirty = false
  for _, ring in pairs(self.rings) do
      dirty = ring:get('dirty') or dirty
  end
  return dirty
end

return Rings
