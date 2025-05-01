local actions = include('lib/actions')
local Ring = include('lib/arrangement/ring')
local Rings = include('lib/arrangement/rings')
local Sequence = include('lib/arrangement/sequence')
local Sequences = include('lib/arrangement/sequences')

local Arrangement = {
  affect_chart = nil,
  affect_console = nil,
  affect_ensemble = nil,
  rings = nil,
  selected_sequence = 1,
  sequences = nil
}

function Arrangement:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Arrangement:hydrate(state)
  self.selected_sequence = state.selected_sequence
  self.sequences:hydrate(state.sequences)
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

function Arrangement:affect(action, index, values)
  if action == actions.toggle_sequence then
    self.sequences:toggle_sequence(index)
  elseif action == actions.toggle_pulse_override then
    self.sequences:toggle_pulse_override(index, values.step)
  elseif action == actions.set_sequence_length then
    self.sequences:set_sequence_length(index, values.length)
  end
end

function Arrangement:pause(sequence)
  if sequence then
    self.sequences:pause_sequence(sequence)
  else
    self.sequences:pause_all()
  end
end

function Arrangement:randomize(sequence)
  if sequence then
    self.sequences:randomize_sequence(sequence)
  else
    self.sequences:randomize_all()
  end
end

function Arrangement:refresh()
  self.rings:refresh()
  self.sequences:refresh()
end

function Arrangement:reset(sequence)
  if sequence then
    self.sequences:reset_sequence(sequence)
  else
    self.sequences:reset_all()
  end
end

function Arrangement:start(sequence)
  if sequence then
    self.sequences:start_sequence(sequence)
  else
    self.sequences:start_all()
  end
end

function Arrangement:step()
  self.sequences:step()
  self.rings:step()
end

function Arrangement:stop(sequence)
  if sequence then
    self.sequences:stop_sequence(sequence)
  else
    self.sequences:stop_all()
  end
end

function Arrangement:press(k, z)
  local mode = get_current_mode()
  if k == 2 and z == 0 then
    if mode == STEP then
      set_current_mode(SEQUENCE)
      self.sequences:transmit(self.selected_sequence)
    end
  elseif k == 3 and z == 0 and not shift_depressed then
    if mode == DEFAULT then
      set_current_mode(SEQUENCE)
      self.sequences:transmit(self.selected_sequence)
    elseif mode == SEQUENCE then
      self.sequences:reset_selected_step(self.selected_sequence)
      self.sequences:enter_step_mode(self.selected_sequence)
    end
  end
end

function Arrangement:twist(e, delta)
  if e == 1 and not shift_depressed then
    local mode = get_current_mode()
    if mode == SEQUENCE then
      self:_select_sequence(delta)
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
  self.sequences:pass_selecion(self.selected_sequence, e, delta)
end

function Arrangement:_emit_note(sequence, note, velocity, envelope_duration)
  local velocity = 100
  self.affect_chart(actions.emit_pulse, sequence, {
    velocity = velocity,
    envelope_duration = envelope_duration
  })
  self.affect_ensemble(actions.play_note, sequence, {
    note = note,
    velocity = velocity,
    envelope_duration = envelope_duration
  })
  if get_current_mode() == DEFAULT then
    self.rings:pulse_ring(sequence)
    self.affect_console(actions.display_note, sequence, {
      note = music_util.note_num_to_name(note),
      velocity = velocity,
      envelope_duration = envelope_duration
    })
  end
end

function Arrangement:_init_observers()
  current_mode:register('arrangement', function() self:_switch_mode() end)
end

function Arrangement:_init_rings()
  local rings = Rings:new({
    delta = function(n, delta) self:_ring_input_to_sequence(n, delta) end
  })
  for i = 1, self.sequences:size() do
    local sequence = self.sequences:get_sequence(i)
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
  local function emit_note(i, note, velocity, envelope_duration)
    self:_emit_note(i, note, velocity, envelope_duration)
  end
  local function transmit_editor_state(editor, i, values)
    self:_transmit_editor_state(editor, i, values) 
  end
  local sequences = Sequences:new()
  sequences:init(emit_note, transmit_editor_state)
  self.sequences = sequences
end

function Arrangement:_ring_input_to_sequence(n, delta)
  if get_current_mode() == DEFAULT then
    set_current_mode(SEQUENCE)
    self.sequences:transmit(n)
    self.selected_sequence = n
  end
  self.sequences:pass_change(self.selected_sequence, n, delta)
end

function Arrangement:_select_sequence(delta)
  self.selected_sequence = util.clamp(self.selected_sequence + delta, 1, self.sequences:size())
  self.sequences:transmit(self.selected_sequence)
end

function Arrangement:_transmit_editor_state(editor, i, state)
  local editor_mode_index = get_mode_index(editor)
  if current_mode() ~= editor_mode_index then
    set_current_mode(editor)
  end

  self.rings:paint_editor_state(state)
  self.affect_console('edit_'..editor, i, state)
  self.affect_chart('edit_'..editor, i, state)
end

return Arrangement