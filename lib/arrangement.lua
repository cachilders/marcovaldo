local Ring = include('lib/arrangement/ring')
local Rings = include('lib/arrangement/rings')
local Sequence = include('lib/arrangement/sequence')

local Arrangement = {
  emit_pulse = nil,
  play_note = nil,
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
  self:_init_sequences()
  self:_init_rings()
end

function Arrangement:refresh()
  self.rings:refresh()
end

function Arrangement:step()
  for i = 1, #self.sequences do
    local sequence = self.sequences[i]
    sequence:step()
    self.rings:step_feedback(i, sequence:get('current_step'))
  end
end

function Arrangement:turn(n, delta)
  self.rings:turn_to_ring(n, delta)
end

function Arrangement:_emit_note(sequencer, note)
  self.emit_pulse(sequencer, 100)
  self.rings:pulse_ring(sequencer)
  self.play_note(sequencer, note)
end

function Arrangement:_init_rings()
  local rings = Rings:new()
  rings:init()
  for i = 1, #self.sequences do
    -- TEMP Ultimately the ring will represent at least two things
    -- and a robust model will be needed to support that
    local sequence = self.sequences[i]
    rings:add(Ring:new({id = i, range = sequence:get('step_count'), x = 1}))
  end
  self.rings = rings
end

function Arrangement:_init_sequences()
  local steps = 16
  for i = 1, 4 do
    local sequence = Sequence:new({
      emitter = function(i, note) self:_emit_note(i, note) end,
      id = i,
      step_count = steps,
      pulse_count = steps
    })
    sequence:init()
    table.insert(self.sequences, sequence)
    steps = steps * 2
  end
end

return Arrangement