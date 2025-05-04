local music_util = require('musicutil')
local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 10 / 127

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

function WDelayPerformer:init()
  self.clocks = {}
end

function WDelayPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  if self.clocks[sequence] then
    clock.cancel(self.clocks[sequence])
  end
  self.clocks[sequence] = clock.run(
    function()
      local feedback = params:get('marco_performer_w_delay_feedback_'..sequence)
      local mix = params:get('marco_performer_w_delay_mix_'..sequence)
      local filter = params:get('marco_performer_w_delay_filter_'..sequence)
      local env_pct = params:get('marco_performer_w_delay_env_pct_'..sequence)
      local rate = params:get('marco_performer_w_delay_rate_'..sequence)
      local mod_rate = params:get('marco_performer_w_delay_mod_rate_'..sequence)
      local mod_amount = params:get('marco_performer_w_delay_mod_amount_'..sequence)
      local clock_mul = params:get('marco_performer_w_delay_clock_mul_'..sequence)
      local clock_div = params:get('marco_performer_w_delay_clock_div_'..sequence)

      crow.ii.wdel[device].feedback(feedback)
      crow.ii.wdel[device].mix(mix)
      crow.ii.wdel[device].filter(filter)
      crow.ii.wdel[device].time(envelope_duration * env_pct / 100)
      crow.ii.wdel[device].rate(rate)
      crow.ii.wdel[device].mod_rate(mod_rate)
      crow.ii.wdel[device].mod_amount(mod_amount)
      crow.ii.wdel[device].clock_ratio(clock_mul, clock_div)
      crow.ii.wdel[device].freq(music_util.note_num_to_freq(note))
      crow.ii.wdel[device].pluck(velocity * VELOCITY_CONSTANT)
      crow.ii.wdel[device].freeze(1)
      clock.sleep(envelope_duration)
      crow.ii.wdel[device].freeze(0)
    end
  )
end

function WDelayPerformer:apply_effect(index, data)
  -- TODO
  -- position( count, divisions ) -- set loop location as a fraction of buffer time (u8)
  -- cut( count, divisions ) -- jump to loop location as a fraction of buffer time (u8)
end

return WDelayPerformer 