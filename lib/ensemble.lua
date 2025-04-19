local actions = include('lib/actions')
local MxSynthsPerformer = include('lib/performers/mx_synths')
local MidiPerformer = include('lib/performers/midi')
local AMPLITUDE_OPERAND = 1/127
local MAX_DISTANCE_OPERAND = .1

local Ensemble = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_console = nil,
  observer_position = nil,
  performers = {},
  source_positions = nil
}

function Ensemble:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  self.observer_position = {0, 0}
  self.source_positions = {}
  self.performers = {}
  return instance
end

function Ensemble:hydrate(ensemble)
  self.observer_position = ensemble.observer_position
  self.source_positions = ensemble.source_positions
end

function Ensemble:init()
  self:add_performer(MxSynthsPerformer:new())
  self:add_performer(MidiPerformer:new())
  self:init_performers()
end

function Ensemble:get(k)
  return self[k]
end

function Ensemble:set(k, v)
  self[k] = v
end

function Ensemble:add_performer(performer)
  self.performers[performer.name] = performer
end

function Ensemble:init_performers()
  for _, performer in pairs(self.performers) do
    performer:init()
  end
end

function Ensemble:affect(action, index, values)
  if action == actions.play_note then
    local voice = index
    local note = values.note
    local velocity = values.velocity or 100
    local envelope_duration = values.envelope_duration
    self:_play_note(voice, note, velocity, envelope_duration)
  elseif action == actions.set_observer_position then
    self.observer_position = values
  elseif action == actions.set_source_positions then
    self.source_positions = values
  elseif action == actions.apply_effect then
    self:_apply_effect(index, values)
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

    operand = 1 - (MAX_DISTANCE_OPERAND * distance)
  end

  return operand
end

function Ensemble:_apply_effect(index, data)
  local performer_name = params:get('marco_performer_'..index)
  local performer = self.performers[performer_name]
  if performer then
    performer:apply_effect(index, data)
  end
end

function Ensemble:_calculate_adjusted_velocity(voice, velocity)
  local distance_operand = self:_get_distance_operand(voice)
  return velocity * distance_operand
end

function Ensemble:_calculate_amplitude(voice, velocity)
  local adjusted_velocity = self:_calculate_adjusted_velocity(voice, velocity)
  return adjusted_velocity * AMPLITUDE_OPERAND
end

function Ensemble:_play_note(voice, note, velocity, envelope_duration)
  local vel = math.floor(self:_calculate_adjusted_velocity(voice, velocity))
  local performer_name = params:get('marco_performer_'..voice)
  local performer = self.performers[performer_name]
  if performer then
    performer:play_note(voice, note, vel, envelope_duration)
  end
end

return Ensemble