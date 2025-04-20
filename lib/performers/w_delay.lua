local Performer = include('lib/performer')

local WDelayPerformer = {
  name = 'W/Delay'
}

setmetatable(WDelayPerformer, { __index = Performer })

function WDelayPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WDelayPerformer:init()
  -- Initialize W/
end

function WDelayPerformer:play_note(sequence, note, velocity, envelope_duration)
  -- Send note to W/
end

function WDelayPerformer:apply_effect(index, data)
  -- no-op
end

return WDelayPerformer 