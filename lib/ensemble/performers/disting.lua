local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 10 / 127

local DistingPerformer = {
  clocks = nil,
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
  local clocks = {}
  for i = 1, 4 do
    clocks[i] = {}
  end
  self.clocks = clocks
end

function DistingPerformer:play_note(sequence, note, velocity, envelope_duration)
  if self.clocks[sequence][note] then
    clock.cancel(self.clocks[sequence][note])
  end

  self.clocks[sequence][note] = clock.run(
    function()
      crow.ii.disting.note_pitch(note, (note - params:get('marco_root')) / 12)
      crow.ii.disting.note_velocity(note, velocity * VELOCITY_CONSTANT)
      clock.sleep(envelope_duration)
      crow.ii.disting.note_off(note)
    end
  )
end

function DistingPerformer:apply_effect(index, data)
  -- control(controller, value)	Set mapped parameter value	0+, 0–16383
  -- no-op
end

return DistingPerformer 