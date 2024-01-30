-- I orchestrate the outputs and provide
-- play_note (arrangement)
-- affect_output (chart: cats)
-- observer_proximity (chart: distance from path step to emitter; loudness/stereoness?)

-- TEMP: Just getting the sequencers in a good place before getting into voice
local Ensemble = {
  scale = nil
}

engine.name = 'PolyPerc'

function Ensemble:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Ensemble:init()
  self.scale = music_util.generate_scale(48, 'Major', 4)
end

function Ensemble:play_note(sequencer, note, velocity, attack, release)
  -- TEMP, see above
  engine.amp(1)
  engine.hz(music_util.note_num_to_freq(music_util.snap_note_to_array(note, self.scale)))
end

return Ensemble