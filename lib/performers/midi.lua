local Performer = require 'lib/performer'

local MidiPerformer = {
  name = 'MIDI'
}

setmetatable(MidiPerformer, { __index = Performer })

function MidiPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiPerformer:init()
  -- Initialize MIDI
end

function MidiPerformer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to MIDI device
end

function MidiPerformer:apply_effect(index, data)
  -- no-op
end

return MidiPerformer 