local Performer = include('lib/ensemble/performer')

local DistingEXPerformer = {
  name = 'Disting EX'
}

setmetatable(DistingEXPerformer, { __index = Performer })

function DistingEXPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DistingEXPerformer:init()
  -- Initialize Disting EX
end

function DistingEXPerformer:play_note(sequence, note, velocity, envelope_duration)
  -- Send note to Disting EX
end

function DistingEXPerformer:apply_effect(index, data)
  -- no-op
end

return DistingEXPerformer 