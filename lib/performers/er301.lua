local Performer = require 'lib/performer'

local ER301Performer = {
  name = 'ER-301'
}

setmetatable(ER301Performer, { __index = Performer })

function ER301Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ER301Performer:init()
  -- Initialize ER-301
end

function ER301Performer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to ER-301
end

function ER301Performer:apply_effect(index, data)
  -- no-op
end

return ER301Performer 