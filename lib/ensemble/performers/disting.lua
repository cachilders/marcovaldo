local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127

local DistingPerformer = {
  name = DIST
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
  self:init_effects()
end

function DistingPerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    -- do something
    clock.sleep(beat_time)
    -- reset
  end
end

function DistingPerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function DistingPerformer:play_note(sequence, note, velocity, envelope_duration)
  local adj_note = note - params:get('marco_root')
  local vo = (adj_note >= 0 and adj_note or 0) / 12

  if self.clocks[sequence][note] then
    clock.cancel(self.clocks[sequence][note])
  end

  self.clocks[sequence][note] = clock.run(
    function()
      crow.ii.disting.note_pitch(note, vo)
      crow.ii.disting.note_velocity(note, velocity * VELOCITY_CONSTANT)
      clock.sleep(envelope_duration)
      crow.ii.disting.note_off(note)
    end
  )
end

return DistingPerformer
