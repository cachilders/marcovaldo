local Performer = include('lib/performer')

local TeletypePerformer = {
  name = 'Teletype'
}

setmetatable(TeletypePerformer, { __index = Performer })

function TeletypePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TeletypePerformer:init()
  -- Initialize Teletype
end

function TeletypePerformer:play_note(sequence, note, velocity, envelope_duration)
  -- Send note to Teletype
end

function TeletypePerformer:apply_effect(index, data)
  -- no-op
end

return TeletypePerformer 