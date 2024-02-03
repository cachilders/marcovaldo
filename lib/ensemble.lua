local actions = include('lib/actions')
local AMPLITUDE_OPERAND = 1/127
local MAX_DISTANCE_OPERAND = .1
local PANE_KEY_MIDPOINT = 32

local Ensemble = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_console = nil,
  observer_position = nil,
  source_positions = nil
}

engine.name='MxSynths'

function Ensemble:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  self.observer_position = {0, 0}
  self.source_positions = {}
  return instance
end

function Ensemble:init()
  local mxsynths_ = include('mx.synths/lib/mx.synths')
  mxsynths = mxsynths_:new()
end

function Ensemble:get(k)
  return self[k]
end

function Ensemble:set(k, v)
  self[k] = v
end

function Ensemble:affect_ensemble(action, index, values)
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
  -- TEMP: This is really specific to mx.synths, and not the plan. Expand and migrate this down
  local mod_reset_value = params:get('mxsynths_mod'..index)
  local beat_time = 60 / params:get('clock_tempo')
  local mod_new_value = (1/PANE_KEY_MIDPOINT) * ((data[1] * data[2]) - PANE_KEY_MIDPOINT)
  clock.run(
    -- This is going to get messy
    function()
      engine.mx_set('mod'..index, mod_new_value)
      clock.sleep(beat_time)
      engine.mx_set('mod'..index, mod_reset_value)
    end
  )
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
  local synth = mxsynths.synths[params:get('mxsynths_synth')]
  mxsynths:play({
    synth = synth,
    note = note,
    velocity = vel,
    attack = envelope_duration * 0.2,
    decay = envelope_duration * 0.25,
    sustain = envelope_duration * 0.2,
    release = envelope_duration * 0.35 -- ¯\_(ツ)_/¯
  })
end

return Ensemble