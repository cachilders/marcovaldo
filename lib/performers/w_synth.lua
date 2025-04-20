local Performer = include('lib/performer')
local VELOCITY_CONSTANT = 5/127 -- to test

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
  -- no-op
end

function WSynthPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device'..sequence)
  local attack = (params:get('marco_attack_'..sequence)*.1) - 5
  crow[device].ii.wsyn.ar_mode(1) -- Investigate alternate options
  crow[device].ii.wsyn.lpg_symmetry(attack)
  crow[device].ii.wsyn.play_note((note  - params:get('marco_root'))/ 12, velocity * VELOCITY_CONSTANT) -- Expand with attack and release as best we can
end

function WSynthPerformer:apply_effect(index, data)
  -- no-op
end

return WSynthPerformer 