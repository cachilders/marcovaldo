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

function DistingPerformer:get_effects()
  return {
    { effect = "algorithm", id = "disting_algorithm" },
    { effect = "parameter_a", id = "disting_param_a" }
  }
end

function DistingPerformer:init()
  print('[DistingPerformer:init] Starting initialization')
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

function DistingPerformer:apply_effect(effect, data)
  print('[DistingPerformer:apply_effect] Received:')
  print('  effect:', effect)
  print('  data:', data)
  if effect.effect == "algorithm" then
    -- TODO: Implement algorithm effect for Disting EX
    print('[DistingPerformer] Applying algorithm effect')
  elseif effect.effect == "parameter_a" then
    -- TODO: Implement parameter A effect for Disting EX
    print('[DistingPerformer] Applying parameter A effect')
  end
end

return DistingPerformer