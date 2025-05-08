local music_util = require('musicutil')
local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5 / 127

local WDelayPerformer = {
  clocks = nil,
  name = 'W/Delay'
}

setmetatable(WDelayPerformer, { __index = Performer })

function WDelayPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WDelayPerformer:get_effects()
  return {
    { effect = "delay_time", id = "wdelay_time" },
    { effect = "feedback", id = "wdelay_feedback" }
  }
end

function WDelayPerformer:init()
  print('[WDelayPerformer:init] Starting initialization')
  self.clocks = {}
end

function WDelayPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  if self.clocks[sequence] then
    clock.cancel(self.clocks[sequence])
  end
  self.clocks[sequence] = clock.run(
    function()
      crow.ii.wdel[device].feedback(params:get('marco_performer_w_feedback_'..sequence))
      crow.ii.wdel[device].mix(params:get('marco_performer_w_mix_'..sequence))
      crow.ii.wdel[device].filter(params:get('marco_performer_w_filter_'..sequence))
      crow.ii.wdel[device].rate(params:get('marco_performer_w_rate_'..sequence))
      crow.ii.wdel[device].mod_rate(params:get('marco_performer_w_mod_rate_'..sequence))
      crow.ii.wdel[device].mod_amount(params:get('marco_performer_w_mod_amount_'..sequence))
      crow.ii.wdel[device].time(envelope_duration / note)
      crow.ii.wdel[device].freq(music_util.note_num_to_freq(note))
      crow.ii.wdel[device].pluck(velocity * VELOCITY_CONSTANT)
      crow.ii.wdel[device].freeze(1)
      clock.sleep(envelope_duration)
      crow.ii.wdel[device].freeze(0)
    end
  )
end

function WDelayPerformer:apply_effect(effect, data)
  print('[WDelayPerformer:apply_effect] Received:')
  print('  effect:', effect)
  print('  data:', data)
  if effect.effect == "delay_time" then
    local mod_reset_value = params:get('wdelay_time')
    local beat_time = 60 / params:get('clock_tempo')
    local mod_new_value = (1/32) * ((data.x * data.y) - 32)
    clock.run(
      function()
        engine.wdelay_set('time', mod_new_value)
        clock.sleep(beat_time)
        engine.wdelay_set('time', mod_reset_value)
      end
    )
  elseif effect.effect == "feedback" then
    local mod_reset_value = params:get('wdelay_feedback')
    local beat_time = 60 / params:get('clock_tempo')
    local mod_new_value = (1/32) * ((data.x * data.y) - 32)
    clock.run(
      function()
        engine.wdelay_set('feedback', mod_new_value)
        clock.sleep(beat_time)
        engine.wdelay_set('feedback', mod_reset_value)
      end
    )
  end
end

return WDelayPerformer