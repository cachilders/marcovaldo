local Sequence = {
  active = true,
  current_step = 1,
  emitter = nil,
  id = 1,
  notes = nil,
  octaves = 1,
  pulse_count = 8,
  pulse_positions = nil,
  pulse_strengths = nil,
  step_count = 8,
  subdivision = 1
}

function Sequence:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Sequence:init()
  self:_init_notes()
  self:_init_pulses()

  -- DEV TEMP
  self:randomize()
end

function Sequence:get(k)
  return self[k]
end

function Sequence:set(k, v)
  self[k] = v
end

function Sequence:randomize()
  self.pulse_count = math.floor(self.step_count * (.1 * math.random(1, 10)))
  self:_distribute_pulses()
  for i = 1, self.step_count do
    self.notes[i] = math.random(36, 72)
    self.pulse_strengths[i] = math.random(37, 117)
  end
end

function Sequence:refresh()
  self:_distribute_pulses()
end

function Sequence:step()
  self:_emit_note()
  self.current_step = util.wrap(self.current_step + 1, 1, self.step_count)
end

function Sequence:_distribute_pulses()
  self.pulse_positions = er.gen(self.pulse_count, self.step_count)
end

function Sequence:_emit_note()
  local step = self.current_step
  if self.notes[step] and self.pulse_positions[step] then
    local pulse_time = (60 / params:get('clock_tempo')) / (self.subdivision * 1.5)
    self.emitter(self.id, self.notes[step], self.pulse_strengths[i], pulse_time)
  end
end

function Sequence:_init_notes()
  self.notes = {}
  for i = 1, self.step_count do
    self.notes[i] = nil
  end
end

function Sequence:_init_pulses()
  self:_distribute_pulses()
  self.pulse_strengths = {}
  for i = 1, self.step_count do
    self.pulse_strengths[i] = 100
  end
end

return Sequence