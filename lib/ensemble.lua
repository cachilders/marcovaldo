-- I orchestrate the outputs and provide
-- play_note (arrangement)
-- affect_output (chart: cats)
-- observer_proximity (chart: distance from path step to emitter; loudness/stereoness?)

-- TEMP: Just getting the sequencers in a good place before getting into voice

local AMPLITUDE_OPERAND = 1/127

local Ensemble = {
  affect_arrangement = function() end,
  affect_chart = function() end,
  affect_console = function() end,
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

function Ensemble:get(k)
  return self[k]
end

function Ensemble:set(k, v)
  self[k] = v
end

function Ensemble:affect_ensemble(action, index, values)
  if action == 'play_note' then
    local voice = index
    local note = values.note
    local velocity = values.velocity or 100
    -- TODO - envelope, etc
    self:_play_note(voice, note, velocity)
  end
end


function Ensemble:_play_note(voice, note, velocity)
  -- TODO - voices, envelope, etc
  engine.amp(AMPLITUDE_OPERAND * velocity)
  engine.hz(music_util.note_num_to_freq(music_util.snap_note_to_array(note, self.scale)))
end

return Ensemble