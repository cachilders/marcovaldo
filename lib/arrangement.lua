local actions = include('lib/actions')
local Ring = include('lib/arrangement/ring')
local Rings = include('lib/arrangement/rings')
local Sequence = include('lib/arrangement/sequence')

local Arrangement = {
  affect_chart = nil,
  affect_console = nil,
  affect_ensemble = nil,
  rings = nil,
  selected_sequence = nil,
  sequences = {}
}

function Arrangement:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Arrangement:init()
  self:_init_observers()
  self:_init_sequences()
  self:_init_rings()
end

function Arrangement:get(k)
  return self[k]
end

function Arrangement:set(k, v)
  self[k] = v
end

function Arrangement:refresh()
  self.rings:refresh()
  self:_transmit_arrangement_state()
end

function Arrangement:step()
  for i = 1, #self.sequences do
    local sequence = self.sequences[i]
    if sequence:get('active') then
      sequence:step()
    end
  end
  self.rings:step()
end


function Arrangement:affect(action, index, values)
  local sequencer = self.sequences[index]
  if action == actions.toggle_sequence then
    sequencer:set('active', not sequencer:get('active'))
  end
end

function Arrangement:turn(n, delta)
  self:_ring_input_to_sequence(n, delta)
end

function Arrangement:twist(e, delta)
  if e == 1 and not shift_depressed then
    local mode = get_current_mode()
    if mode == SEQUENCE then
      self:_select_secuence(d)
    elseif mode == STEP then
      self:_encoder_input_to_sequence(e, delta)
    end
  elseif e == 1 and shift_depressed then
    -- TBD
  elseif e == 2 and not shift_depressed then
    self:_ring_input_to_sequence(1, delta)
  elseif e == 3 and not shift_depressed then
    self:_ring_input_to_sequence(2, delta)
  elseif e == 2 and shift_depressed then
    self:_ring_input_to_sequence(3, delta)
  elseif e == 3 and shift_depressed then
    self:_ring_input_to_sequence(4, delta)
  end
end

function Arrangement:_encoder_input_to_sequence(e, delta)
  self.sequences[self.selected_sequence]:select(delta)
end

function Arrangement:_ring_input_to_sequence(n, delta)
  if get_current_mode() == DEFAULT or not self.selected_sequence then
    set_current_mode(SEQUENCE)
    self.selected_sequence = n
  else
    self.sequences[self.selected_sequence]:change(n, delta)
  end
end

function Arrangement:_emit_note(sequencer, note, velocity, envelope_duration)
  local velocity = 100
  self.affect_chart(actions.emit_pulse, sequencer, {
    velocity = velocity,
    envelope_duration = envelope_duration
  })
  self.affect_ensemble(actions.play_note, sequencer, {
    note = note,
    velocity = velocity,
    envelope_duration = envelope_duration
  })
  if get_current_mode() == DEFAULT then
    self.rings:pulse_ring(sequencer)
  end
end

function Arrangement:_init_observers()
  current_mode:register('arrangement', function() self:_switch_mode() end)
end

function Arrangement:_init_rings()
  local rings = Rings:new()
  for i = 1, #self.sequences do
    local sequence = self.sequences[i]
    rings:add(Ring:new({
      id = i,
      context = sequence
    }))
  end
  rings:set('context', self.sequences)
  rings:init()
  self.rings = rings
end

function Arrangement:_init_sequences()
  local steps = 16
  local subdivision = 1
  for i = 1, 4 do
    local sequence = Sequence:new({
      transmit_edit_state = function(i, values) self:_transmit_edit_state(SEQUENCE, i, values) end,
      transmit_edit_step = function(i, values) self:_transmit_edit_state(STEP, i, values) end,
      emitter = function(i, note, velocity, envelope_duration) self:_emit_note(i, note, velocity, envelope_duration) end,
      id = i,
      step_count = steps,
      pulse_count = steps,
      subdivision = subdivision
    })
    sequence:init()
    table.insert(self.sequences, sequence)
    steps = steps * 2
    subdivision = subdivision * 2
  end
end

function Arrangement:_transmit_edit_state(editor, i, values)
  local editor_mode_index = get_mode_index(editor)
  if current_mode() ~= editor_mode_index then
    set_current_mode(editor)
  end

  self.affect_console('edit_'..editor, i, values)
end

function Arrangement:_transmit_arrangement_state()
  if get_current_mode() == DEFAULT then
    local values = {}
    for i = 1, #self.sequences do
      values['Sequencer '..i..' step'] = self.sequences[i]:get('current_step')
    end
    self.affect_console(actions.transmit_edit_state, '', values)
  end
end

return Arrangement