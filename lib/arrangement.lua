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
  selcted_step = nil,
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
      if get_current_mode() == DEFAULT then
        self.rings:step_feedback(i, sequence:get('current_step'))
      end
    end
  end
end

function Arrangement:turn(n, delta)
  self:_pass_input_to_sequence(n, delta)
end

function Arrangement:affect(action, index, values)
  local sequencer = self.sequences[index]
  if action == actions.toggle_sequence then
    sequencer:set('active', not sequencer:get('active'))
  end
end

function Arrangement:_pass_input_to_sequence(n, delta)
  if get_current_mode() == DEFAULT then
    -- TODO Context needs to switch to TOUCHED sequencer
    -- change with ENC1 turn to others. Right now we're
    -- just testing mode change and timeout
    set_current_mode(SEQUENCE)
  else
    self.sequences[n]:change(delta)
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
  local editor_mode_index = tab.key(MODES, editor)
  if current_mode() ~= editor_mode_index then
    set_current_mode(editor_mode_index)
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