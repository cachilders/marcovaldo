local music_util = require('musicutil')
local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5 / 127
local NOTE_CONSTANT = 1/127

local WDelayPerformer = {
  name = WD
}

setmetatable(WDelayPerformer, { __index = Performer })

function WDelayPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WDelayPerformer:init()
  self.clocks = {}
  self.divisions = 1
  self.repeats = 1
  self:init_effects()
end

function WDelayPerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    clock.run(
      function()
        self.divisions = data.x
        self.repeats = data.y
        clock.sleep(beat_time)
        self.divisions = 1
        self.repeats = 1
      end
    )
  end
end

function WDelayPerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function WDelayPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  local divided_duration = envelope_duration / self.divisions
  local repeats = self.repeats <= self.divisions and self.repeats or self.divisions
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * self.repeats)) / (repeats - 1) or 0
  local time
  if params:get('marco_performer_w_env_time_variant_'..sequence) == 1 then
    time = divided_duration / note
  else
    time = divided_duration * (1 - (note * NOTE_CONSTANT))
  end
  crow.ii.wdel[device].feedback(params:get('marco_performer_w_feedback_'..sequence))
  crow.ii.wdel[device].filter(params:get('marco_performer_w_filter_'..sequence))
  crow.ii.wdel[device].rate(params:get('marco_performer_w_rate_'..sequence))
  crow.ii.wdel[device].mod_rate(params:get('marco_performer_w_mod_rate_'..sequence))
  crow.ii.wdel[device].mod_amount(params:get('marco_performer_w_mod_amount_'..sequence))
  crow.ii.wdel[device].time(time)
  crow.ii.wdel[device].freq(music_util.note_num_to_freq(note))
  for i = 1, self.repeats do
    if self.clocks[sequence] then
      clock.cancel(self.clocks[sequence])
    end
    self.clocks[sequence] = clock.run(
      function()
        crow.ii.wdel[device].pluck(velocity * VELOCITY_CONSTANT)
        crow.ii.wdel[device].freeze(1)
        clock.sleep(divided_duration)
        crow.ii.wdel[device].freeze(0)
        if self.repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return WDelayPerformer
