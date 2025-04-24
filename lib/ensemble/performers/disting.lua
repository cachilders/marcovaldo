local Performer = include('lib/ensemble/performer')

local DistingPerformer = {
  name = 'Disting'
}

setmetatable(DistingPerformer, { __index = Performer })

function DistingPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DistingPerformer:init()
  -- Initialize Disting EX
end

-- note_pitch(channel, note, velocity)	Note On (with velocity)	1–16, 0–127, 0–127
-- note_velocity(channel, note, velocity)	Change velocity of held note	1–16, 0–127, 0–127
-- note_off(channel, note)	Note Off	1–16, 0–127
-- control(controller, value)	Set mapped parameter value	0+, 0–16383

function DistingPerformer:play_note(sequence, note, velocity, envelope_duration)
  -- Send note to Disting EX
end

function DistingPerformer:apply_effect(index, data)
  -- no-op
end

return DistingPerformer 