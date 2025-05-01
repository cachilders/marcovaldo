local Sequence = include('lib/arrangement/sequence')

local Sequences = {
  sequences = nil
}

function Sequences:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Sequences:init(emit_note, transmit_editor_state)
  self:_init_sequences(emit_note, transmit_editor_state)
end

function Sequences:enter_step_mode(sequence)
  self.sequences[sequence]:enter_step_mode()
end

function Sequences:hydrate(sequences)
  local sequences = sequences.sequences
  for i = 1, #sequences do
    self.sequences[i]:hydrate(sequences[i])
  end
end

function Sequences:get_sequence(sequence)
  return self.sequences[sequence]
end

function Sequences:pass_change(sequence, n, delta)
  self.sequences[sequence]:change(n, delta)
end

function Sequences:pass_selecion(sequence, e, delta)
  self.sequences[sequence]:select(e, delta)
end

function Sequences:pause_all()
  for i = 1, #self.sequences do
    self:pause_sequence(i)
  end 
end

function Sequences:pause_sequence(sequence)
  self.sequences[sequence]:pause()
end

function Sequences:randomize_all()
  for i = 1, #self.sequences do
    self:randomize_sequence(i)
  end 
end

function Sequences:randomize_sequence(sequence)
  self.sequences[sequence]:randomize()
end

function Sequences:reset_all()
  for i = 1, #self.sequences do
    self:reset_sequence(i)
  end 
end

function Sequences:reset_sequence(sequence)
  self.sequences[sequence]:init()
end

function Sequences:refresh()
  for i = 1, #self.sequences do
    self.sequences[i]:refresh()
  end
end

function Sequences:reset_selected_step(sequence)
  self.sequences[sequence]:reset_selected_step()
end

function Sequences:size()
  return #self.sequences
end

function Sequences:step()
  for i = 1, #self.sequences do
    local sequence = self.sequences[i]
    if sequence:get('active') then
      sequence:step()
      current_steps[i]:set(sequence:get('current_step'))
    end
  end
end

function Sequences:start_all()
  for i = 1, #self.sequences do
    self:start_sequence(i)
  end 
end

function Sequences:start_sequence(sequence)
  self.sequences[sequence]:start()
end

function Sequences:stop_all()
  for i = 1, #self.sequences do
    self:stop_sequence(i)
  end 
end

function Sequences:stop_sequence(sequence)
  self.sequences[sequence]:stop()
end

function Sequences:toggle_sequence(sequence)
  local sequence = self.sequences[sequence]
  sequence:set('active', not sequence:get('active'))
end

function Sequences:transmit(n)
  self.sequences[n]:transmit()
end

function Sequences:_init_sequences(emit_note, transmit_editor_state)
  local sequences = {}
  local octaves = 1
  local steps = 16
  local subdivision = 1
  for i = 1, 4 do
    local sequence = Sequence:new({
      active = false,
      emit_note = emit_note,
      id = i,
      octaves = octaves,
      selected_step = 1,
      step_count = steps,
      subdivision = subdivision,
      transmit_editor_state = transmit_editor_state
    })
    sequence:init()
    table.insert(sequences, sequence)
    steps = steps * 2
    subdivision = subdivision + 1
    octaves = octaves + 1
  end
  self.sequences = sequences
end

return Sequences