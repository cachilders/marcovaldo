local Sequence = {
  current_step = 1,
  emitter = nil,
  id = 1,
  notes = nil,
  octaves = 1,
  pulse_count = 8,
  pulses = nil,
  step_count = 8
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
  self.current_step = util.wrap(self.current_step + 1, 1, self.step_count)
end

function Sequence:_distribute_pulses()
  self.pulses = er.gen(self.pulse_count, self.step_count)
end

function Sequence:_emit_note()
  local step = self.current_step
  if self.notes[step] and self.pulses[step] then
    self.emitter({emitter = self.id, note = self.notes[step]})
  end
end

function Sequence:_init_notes()
  self.notes = {}
  for i = 1, self.step_count do
    self.notes[i] = nil
  end
end

function Sequence:_update_steps()
  for i = 1, self.step_count do
    if not self.notes[i] then
      self.notes[i] = nil
    end
  end
end

return Sequence