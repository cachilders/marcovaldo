local Sequence = {
  emitter = nil,
  notes = nil,
  octaves = 1,
  pulses = 8,
  step = 1,
  steps = 8
}

function Sequence:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Sequence:init()
  self:_distribute_pulses()
  self:_init_notes()
end

function Sequence:randomize()
  -- TODO: Random notes quantized to scale
  -- within octave range from root
end

function Sequence:refresh()
  self:_distribute_pulses()
end

function Sequence:step()
  self:_emit_note()
  self.step = util.wrap(step.step + 1, 1, self.steps)
end

function Sequence:_distribute_pulses()
  -- Euclid
end

function Sequence:_emit_note()
  if self.notes[self.step] then
    self.emitter:emit_note(self.notes[self.step])
  end
end

function Sequence:_init_notes()
  self.notes = {}
  for i = 1, self.steps do
    self.notes[i] = nil
  end
end

function Sequence:_update_steps()
  for i = 1, self.steps do
    if not self.notes[i] then
      self.notes[i] = nil
    end
  end
end

return Sequence