local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 63 / 127

local WDelayPerformer = {
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
  -- Initialize W/
end

-- feedback( level ) -- amount of feedback from read head to write head (s16V)
-- mix( fade ) -- fade from dry to delayed signal (s16V)
-- filter( cutoff ) -- centre frequency of filter in feedback loop (s16V)
-- freeze( is_active ) -- deactivate record head to freeze the current buffer (s8)
-- time( seconds ) -- set delay buffer length in seconds, when rate == 1 (s16V)
-- length( count, divisions ) -- set buffer loop size as a fraction of buffer time (u8)
-- position( count, divisions ) -- set loop location as a fraction of buffer time (u8)
-- cut( count, divisions ) -- jump to loop location as a fraction of buffer time (u8)
-- rate( multiplier ) -- direct multiplier of tape speed (s16V)
-- freq( volts ) -- manipulate tape speed with musical values (s16V)
-- clock() -- receive clock pulse for synchronization
-- clock_ratio( mul, div ) -- set clock pulses per buffer time, with clock mul/div (s8)
-- pluck( volume ) -- pluck the delay line with noise at volume (s16V)
-- mod_rate ( rate ) -- set the multiplier for the modulation rate (s16V)
-- mod_amount( amount ) -- set the amount of delay line modulation to be applied (s16V)


function WDelayPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  crow.ii.w_delay[device].freq(note / 12)
  crow.ii.w_delay[device].pluck(velocity * VELOCITY_CONSTANT)
end

function WDelayPerformer:apply_effect(index, data)
  -- no-op
end

return WDelayPerformer 