local DEFAULT_MIN = 1
local MIDI_MAX = 127
local OCTAVES_MAX = 10
local PULSE_WIDTH_MIN = 50
local PULSE_WIDTH_MAX = 150
local SUBDIVISION_LABELS = {'1/4', '1/8', '1/8t', '1/16'}
local STEP_COUNT_MIN = 8
local STEP_COUNT_MAX = 128

local Sequence = {
  active = true,
  current_step = 1,
  emitter = nil,
  id = 1,
  notes = nil,
  octaves = 1,
  pulse_count = STEP_COUNT_MIN,
  pulse_positions = nil,
  pulse_strengths = nil,
  pulse_widths = nil,
  scale = nil,
  selected_step = 1,
  step_count = STEP_COUNT_MIN,
  subdivision = 1,
  throttles = nil,
  transmit_edit_sequence = nil,
  transmit_edit_step = nil
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
  self:_init_throttles()
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
  local mode = get_current_mode()
  self:_distribute_pulses()
end

function Sequence:step()
  self:_emit_note()
  self.current_step = util.wrap(self.current_step + 1, 1, self.step_count)
end

function Sequence:change(n, delta)
  if not self.throttles[n] then
    self.throttles[n] = true
    local mode = get_current_mode()
    if mode == SEQUENCE then
      if n == 1 then
        self:_adjust_step_count(delta)
      elseif n == 2 then
        self:_adjust_pulse_count(delta)
      elseif n == 3 then
        self:_adjust_octaves(delta)
      elseif n == 4 then
        self:_adjust_subdivision(delta)
      end
    elseif mode == STEP then
      if n == 1 then
        self:_set_step_note(delta)
      elseif n == 2 then
        -- TODO this one won't actually work
        -- with pulses being redistributed
        self:_set_step_pulse_active(delta)
      elseif n == 3 then
        self:_set_step_pulse_strength(delta)
      elseif n == 4 then
        self:_set_step_pulse_width(delta)
      end
    end
  
    if self.selected_step > self.step_count or not self.selected_step then
      self.selected_step = 1
    end
  
    self:_gather_and_transmit_edit_state(mode)
    default_mode_timeout_extend()

    clock.run(function()
      -- TODO Scale it
      clock.sleep(.05)
      self.throttles[n] = false
    end)
  end
end

function Sequence:_adjust_pulse_count(delta)
  self.pulse_count = util.clamp(self.pulse_count + delta, 0, self.step_count)
  self:_distribute_pulses()
end

function Sequence:_adjust_step_count(delta)
  self.step_count = util.clamp(self.step_count + delta, STEP_COUNT_MIN, STEP_COUNT_MAX)
  self:_adjust_pulse_count(0)
end

function Sequence:_adjust_octaves(delta)
  self.octaves = util.clamp(self.octaves + delta, DEFAULT_MIN, OCTAVES_MAX)
  self:_set_scale()
end

function Sequence:_adjust_subdivision(delta)
  self.subdivision = util.clamp(self.subdivision + delta, DEFAULT_MIN, #SUBDIVISION_LABELS)
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

function Sequence:_gather_and_transmit_edit_state(mode)
  if mode == SEQUENCE then
    local values = {
      self.step_count,
      self.pulse_count,
      self.octaves,
      self.subdivision,
    }
    local ranges = {
      STEP_COUNT_MAX - STEP_COUNT_MIN,
      self.step_count,
      OCTAVES_MAX,
      #SUBDIVISION_LABELS
    }
    self.transmit_edit_sequence(self.id, {values, ranges})
  elseif mode == STEP then
    local step = self.selected_step
    local values = {
      self.notes[step],
      self.pulse_positions[step],
      self.pulse_strengths[step],
      self.pulse_widths[step],
    }
    local ranges = {
      #self.scale,
      2, -- TODO standin
      MIDI_MAX,
      PULSE_WIDTH_MAX - PULSE_WIDTH_MIN
    }
    self.transmit_edit_step(step, {values, ranges})
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

function Sequence:_init_throttles()
  throttles = {}
  for i = 1, 4 do
    throttles[i] = false
  end
  self.throttles = throttles
end

function Sequence:_interpret_note_position_within_scale(note)

  local snapped_note = music_util.snap_note_to_array(note, self.scale)
  local note_index = tab.key(self.scale, snapped_note)
  return note_index
end

function Sequence:select(e, delta)
  if e == 1 then
    self:_select_edit_step(delta)
    self._gather_and_transmit_edit_state(STEP)
  end
end

function Sequence:_select_edit_step(delta)
  self.selected_step = util.clamp(self.selected_step + delta, 1, self.step_count)
end

function Sequence:_set_step_note(delta)
    -- TODO Should be able to selct no note
    -- Also the note index piece is basically unusable
  local selected_note = self.notes[self.selected_step]
  local note_index_within_scale = 1
  if selected_note then
    local note_index_within_scale = self:_interpret_note_position_within_scale(selected_note)
  end
  selected_note = self.scale[util.clamp(note_index_within_scale + delta, 1, #self.scale)]
  self.notes[self.selected_step] = selected_note
end

function Sequence:_set_step_pulse_active(delta)
  -- TODO This is overidden by the auto pulse distro and something has to change
  local pulse_binary = self.pulse_positions[self.selected_step] and 1 or 0
  self.pulse_positions[self.selected_step] = util.clamp(pulse_binary + delta, 0, 1) == 1
end

function Sequence:_set_step_pulse_strength(delta)
  self.pulse_strengths[self.selected_step] = util.clamp(self.pulse_strengths[self.selected_step] + delta, DEFAULT_MIN, MIDI_MAX)
end

function Sequence:_set_step_pulse_width(delta)
  self.pulse_widths[self.selected_step] = util.clamp(self.pulse_widths[self.selected_step] + delta, PULSE_WIDTH_MIN, PULSE_WIDTH_MAX)
end

function Sequence:_set_scale()
  -- TODO TRANSPOSE
  self.scale = music_util.generate_scale(
    parameters.root(),
    parameters.scale(),
    self.octaves
  )
end

return Sequence