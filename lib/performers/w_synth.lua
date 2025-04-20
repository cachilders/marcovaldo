local Performer = include('lib/performer')

local WSynthPerformer = {
  name = 'W/Synth'
}

setmetatable(WSynthPerformer, { __index = Performer })

function WSynthPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSynthPerformer:init()
  -- Initialize W/
end

function WSynthPerformer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to W/
end

function WSynthPerformer:apply_effect(index, data)
  -- no-op
end

return WSynthPerformer 