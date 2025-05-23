local actions = include('lib/actions')
local AnsiblePerformer = include('lib/ensemble/performers/ansible')
local CrowPerformer = include('lib/ensemble/performers/crow')
local DistingPerformer = include('lib/ensemble/performers/disting')
local ER301Performer = include('lib/ensemble/performers/er301')
local JustFriendsPerformer = include('lib/ensemble/performers/just_friends')
local MidiPerformer = include('lib/ensemble/performers/midi')
local MxSynthsPerformer = include('lib/ensemble/performers/mx_synths')
local WDelayPerformer = include('lib/ensemble/performers/w_delay')
local WSynthPerformer = include('lib/ensemble/performers/w_synth')
local WTapePerformer = include('lib/ensemble/performers/w_tape')

local AMPLITUDE_OPERAND = 1/127
local MAX_DISTANCE_OPERAND = .1

local Ensemble = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_console = nil,
  observer_position = nil,
  performers = nil,
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
  self:add_performer(MidiPerformer:new())
  self:add_performer(AnsiblePerformer:new())
  self:add_performer(CrowPerformer:new())
  self:add_performer(DistingPerformer:new())
  self:add_performer(ER301Performer:new())
  self:add_performer(MxSynthsPerformer:new())
  self:add_performer(JustFriendsPerformer:new())
  self:add_performer(WDelayPerformer:new())
  self:add_performer(WSynthPerformer:new())
  self:add_performer(WTapePerformer:new())
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
  local sequence = index
  if action == actions.play_note then
    local note = values.note
    local velocity = values.velocity or 100
    local envelope_duration = values.envelope_duration
    self:_play_note(sequence, note, velocity, envelope_duration)
  elseif action == actions.set_observer_position then
    self.observer_position = values
  elseif action == actions.set_source_positions then
    self.source_positions = values
  elseif action == actions.apply_effect then
    local effect_enabled_performers = {}
    local performer
    for i = 1, 4 do
      if params:get('marco_performer_cats_'..i) == 2 then
        table.insert(effect_enabled_performers, i)
      end
    end
    if params:get('marco_wrong_stop') == 2 then
      table.insert(effect_enabled_performers, WRONG_STOP_SEQ)
    end
    if sequence <= 4 and tab.contains(effect_enabled_performers, sequence) then
      performer = self.performers[parameters:get_performer(sequence)]
    elseif #effect_enabled_performers > 0 then
      local replacement_performer_index = effect_enabled_performers[math.random(1, #effect_enabled_performers)]
      if replacement_performer_index == WRONG_STOP_SEQ then
        performer = self.performers[WT]
      else
        performer = self.performers[parameters:get_performer(replacement_performer_index)]
      end
    end
    if performer then
      performer:apply_effect(values.effect, values.data, sequence)
    end
  end
end

function Ensemble:configure(performer, options)
  if self.performers and self.performers[performer] then
    self.performers[performer]:configure(options)
  end
end

function Ensemble:midi_transmit_cc(sequence)
  if self.performers and self.performers[MIDI] then
    self.performers[MIDI]:transmit_cc(sequence)
  end
end

function Ensemble:midi_panic()
  self.performers[MIDI]:panic()
end

function Ensemble:midi_cc_reset()
  self.performers[MIDI]:cc_reset()
end

function Ensemble:_get_distance_operand(sequence)
  local operand = 1
  local x = self.observer_position[1]
  local y = self.observer_position[2]

  if x > 0 and y > 0 then
    local source_x = self.source_positions[sequence][1]
    local source_y = self.source_positions[sequence][2]
    local distance = distance_between(x, y, source_x, source_y)

    operand = 1 - (MAX_DISTANCE_OPERAND * distance)
  end

  return operand
end

function Ensemble:_calculate_adjusted_velocity(sequence, velocity)
  local distance_operand = self:_get_distance_operand(sequence)
  return velocity * distance_operand
end

function Ensemble:_calculate_amplitude(sequence, velocity)
  local adjusted_velocity = self:_calculate_adjusted_velocity(sequence, velocity)
  return adjusted_velocity * AMPLITUDE_OPERAND
end

function Ensemble:_play_note(sequence, note, velocity, envelope_duration)
  local vel = math.floor(self:_calculate_adjusted_velocity(sequence, velocity))
  local performer_name = parameters:get_performer(sequence)
  local performer = self.performers[performer_name]
  if performer then
    performer:play_note(sequence, note, vel, envelope_duration)
  end
end

return Ensemble
