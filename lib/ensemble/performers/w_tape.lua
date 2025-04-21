local Performer = include('lib/ensemble/performer')

local WTapePerformer = {
  name = 'W/Tape'
}

setmetatable(WTapePerformer, { __index = Performer })

function WTapePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WTapePerformer:init()
  -- Initialize W/
end

function WTapePerformer:play_note(sequence, note, velocity, envelope_duration)
  -- Send note to W/
end

function WTapePerformer:apply_effect(index, data)
  -- no-op
end

return WTapePerformer 