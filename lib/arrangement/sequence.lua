local SUBDIVISION_LABELS = {'1/4', '1/8', '1/8t', '1/16'}

local Sequence = {
  active = true,
  current_step = 1,
  edit_step = 1,
  emitter = nil,
  id = 1,
  notes = nil,
  octaves = 1,
  pulse_count = 8,
  pulse_positions = nil,
  pulse_strengths = nil,
  pulse_widths = nil,
  scale = nil,
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
  self:_init_observers()
  self:_init_pulses()
  self:_set_scale()
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
    self.pulse_widths[i] = math.random(50, 150)
  end
end

function Sequence:refresh()
  self:_distribute_pulses()
end

function Sequence:step()
  self:_emit_note()
  self.current_step = util.wrap(self.current_step + 1, 1, self.step_count)
end

function Sequence:_adjust_pulse_count(delta)
  self.pulse_count = util.clamp(self.pulse_count + delta, 8, self.step_count)
  self:_distribute_pulses()
end

function Sequence:_adjust_step_count(delta)
  self.step_count = util.clamp(self.step_count + delta, 8, 128)
  self:_adjust_pulse_count(0)
end

function Sequence:_adjust_octaves(delta)
  self.octaves = util.clamp(self.octaves + delta, 1, 10)
  self:_set_scale()
end

function Sequence:_adjust_subdivision(delta)
  self.subdivision = util.clamp(self.subdivision + delta, 1, 4)
end

function Sequence:_calculate_pulse_time(step)
  local bpm = 60 / params:get('clock_tempo')
  local cosmological_constant = params:get('marco_pulse_constant') / 100
  local subdivided_bpm = bpm / (self.subdivision * cosmological_constant)
  local width_modifier = (self.pulse_widths[step] or 100) / 100
  return subdivided_bpm * width_modifier
end

function Sequence:_distribute_pulses()
  self.pulse_positions = er.gen(self.pulse_count, self.step_count)
end

function Sequence:_emit_note()
  local step = self.current_step
  if self.notes[step] and self.pulse_positions[step] then
    local velocity = self.pulse_strengths[step] or 100
    local envelope_duration = self:_calculate_pulse_time(step)
    local quantized_note = music_util.snap_note_to_array(self.notes[step], self.scale)
    self.emitter(self.id, quantized_note, velocity, envelope_duration)
  end
end

function Sequence:_init_notes()
  self.notes = {}
  for i = 1, self.step_count do
    self.notes[i] = nil
  end
end

function Sequence:_init_observers()
  parameters.scale:register('seq'..self.id, function() self:_set_scale() end)
  parameters.root:register('seq'..self.id, function() self:_set_scale() end)
end

function Sequence:_init_pulses()
  self:_distribute_pulses()
  self.pulse_strengths = {}
  self.pulse_widths = {}
  for i = 1, self.step_count do
    self.pulse_strengths[i] = 100
    self.pulse_widths[i] = 100
  end
end

function Sequence:_select_edit_step(delta)
  self.edit_step = util.clamp(self.edit_step + delta, 1, self.step_count)
end

function Sequence:_set_step_note(step, delta)
  self.notes[step] = util.clamp(self.notes[step] + delta, 1, #self.scale)
end

function Sequence:_set_step_pulse_strength(step, delta)
  self.pulse_strengths[step] = util.clamp(self.pulse_strengths[step] + delta, 1, 127)
end

function Sequence:_set_step_pulse_width(step, delta)
  self.pulse_widths[step] = util.clamp(self.pulse_widths[step] + delta, 50, 150)
end

function Sequence:_set_scale()
  -- TODO TRANSPOSE
  self.scale = music_util.generate_scale(
    parameters.root(),
    parameters.scale(),
    self.octaves
  )
end

function Sequence:_toggle_step_pulse_position(step)
  -- TODO ¯\_(ツ)_/¯
end

return Sequence