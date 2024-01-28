local Ring = include('lib/arrangement/ring')
local Rings = include('lib/arrangement/rings')
local Sequence = include('lib/arrangement/sequence')

local Arrangement = {
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
end

function Arrangement:turn(n, delta)
  self.rings:turn_to_ring(n, delta)
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
  local steps = 8
  for i = 1, 4 do
    local sequence = Sequence:new({
      emitter = function(n) print('Emitting '..n) end,
      steps = steps
    })
    sequence:init()
    table.insert(self.sequences, sequence)
    steps = steps * 2
  end
end

return Arrangement