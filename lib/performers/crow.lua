local Performer = require 'lib/performer'

local CrowPerformer = {
  name = 'Crow'
}

setmetatable(CrowPerformer, { __index = Performer })

function CrowPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowPerformer:init()
  -- Initialize Crow
end

function CrowPerformer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to Crow
end

function CrowPerformer:apply_effect(index, data)
  -- no-op
end

return CrowPerformer 