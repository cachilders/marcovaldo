local Performer = require 'lib/performer'

local WPerformer = {
  name = 'W/'
}

setmetatable(WPerformer, { __index = Performer })

function WPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WPerformer:init()
  -- Initialize W/
end

function WPerformer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to W/
end

function WPerformer:apply_effect(index, data)
  -- no-op
end

return WPerformer 