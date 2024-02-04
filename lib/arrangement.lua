local actions = include('lib/actions')
local Ring = include('lib/arrangement/ring')
local Rings = include('lib/arrangement/rings')
local Sequence = include('lib/arrangement/sequence')

local Arrangement = {
  affect_chart = nil,
  affect_console = nil,
  affect_ensemble = nil,
  rings = nil,
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
end

function Arrangement:step()
  for i = 1, #self.sequences do
    local sequence = self.sequences[i]
    if sequence:get('active') then
      sequence:step()
      self.rings:step_feedback(i, sequence:get('current_step'))
    end
  end
end

function Arrangement:turn(n, delta)
  self.rings:turn_to_ring(n, delta)
end

function Arrangement:affect(action, index, values)
  local sequencer = self.sequences[index]
  if action == actions.toggle_sequence then
    sequencer:set('active', not sequencer:get('active'))
  end
end

function Arrangement:_emit_note(sequencer, note, velocity, envelope_duration)
  local velocity = 100
  self.affect_chart(actions.emit_pulse, sequencer, {
    velocity = velocity,
    envelope_duration = envelope_duration
  })
  self.rings:pulse_ring(sequencer)
  self.affect_ensemble(actions.play_note, sequencer, {
    note = note,
    velocity = velocity,
    envelope_duration = envelope_duration
  })
end

function Arrangement:_init_observers()
  current_mode:register('arrangement', function() self:_switch_mode() end)
end

function Arrangement:_init_rings()
  local rings = Rings:new()
  rings:init()
  for i = 1, #self.sequences do
    -- TEMP Ultimately the ring will represent at least two things
    -- and a robust model will be needed to support that
    local sequence = self.sequences[i]
    rings:add(Ring:new({
      id = i,
      range = sequence:get('step_count'),
      x = 1
    }))
  end
  self.rings = rings
end

function Arrangement:_init_sequences()
  local steps = 16
  local subdivision = 1
  for i = 1, 4 do
    local sequence = Sequence:new({
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

function Arrangement:_switch_mode()
  -- do stuff
end

return Arrangement