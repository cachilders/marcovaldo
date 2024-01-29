local Ring = include('lib/arrangement/ring')
local Rings = include('lib/arrangement/rings')
local Sequence = include('lib/arrangement/sequence')

local Arrangement = {
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
    self.sequences[i]:step()
  end
end

function Arrangement:turn(n, delta)
  self.rings:turn_to_ring(n, delta)
end

function Arrangement:_emit_note(sequencer, note)
  -- TEMP
  self.play_note(sequencer, note)
end

function Arrangement:_init_rings()
  local rings = Rings:new()
  rings:init()
  rings:add(Ring:new({id = 1, range = 16, x = 1}))
  rings:add(Ring:new({id = 2, range = 8, x = 1}))
  rings:add(Ring:new({id = 3, range = 32, x = 1}))
  rings:add(Ring:new({id = 4, range = 64, x = 1}))
  self.rings = rings
end

function Arrangement:_init_sequences()
  local steps = 16
  for i = 1, 4 do
    local sequence = Sequence:new({
      emitter = function(i, note) self:_emit_note(i, note) end,
      id = i,
      step_count = steps,
      -- REALLY JUST JAMMING ON TEMP
      pulse_count = math.floor(steps * (.1 * math.random(1, 10)))
    })
    sequence:init()
    table.insert(self.sequences, sequence)
    steps = steps * 2
  end
end

return Arrangement