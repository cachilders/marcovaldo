local AMPLITUDE_OPERAND = 1/127
local MAX_DISTANCE_OPERAND = 1/9

local Ensemble = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_console = nil,
  observer_position = {0, 0},
  scale = nil,
  source_positions = {}
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
  elseif action == 'set_observer_position' then
    self.observer_position = values
  elseif action == 'set_source_positions' then
    self.source_positions = values
  end
end

function Ensemble:_get_distance_operand(voice)
  local operand = 1
  local x = self.observer_position[1]
  local y = self.observer_position[2]

  if x > 0 and y > 0 then
    local source_x = self.source_positions[voice][1]
    local source_y = self.source_positions[voice][2]
    local distance = distance_between(x, y, source_x, source_y)

    if distance > 0 then
      operand = 1 - (MAX_DISTANCE_OPERAND * distance)
    end
  end

  return operand
end

function Ensemble:_calculate_amplitude(voice, velocity)
  local distance_operand = self:_get_distance_operand(voice)
  local amplitude = AMPLITUDE_OPERAND * velocity
  return amplitude * distance_operand
end

function Ensemble:_play_note(voice, note, velocity)
  -- TODO - voices, envelope, etc
  engine.amp(self:_calculate_amplitude(voice, velocity))
  engine.hz(music_util.note_num_to_freq(music_util.snap_note_to_array(note, self.scale)))
end

return Ensemble