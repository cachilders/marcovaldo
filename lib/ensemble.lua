-- I orchestrate the outputs and provide
-- play_note (arrangement)
-- effect_output (chart: cats)
-- observer_proximity (chart: distance from path step to emitter; loudness/stereoness?)
local Ensemble = {}
-- TEMP
engine.name = 'PolyPerc'

function Ensemble:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Ensemble:init()
  -- big TEMP
end

function Ensemble:play_note(sequencer, note, velocity, attack, release)
  -- Also big temp
  engine.amp(1)
  engine.hz(music_util.note_num_to_freq(note))
end

return Ensemble