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
      crow.ii.wdel[device].time(envelope_duration / note)
      crow.ii.wdel[device].freq(music_util.note_num_to_freq(note))
      crow.ii.wdel[device].pluck(velocity * VELOCITY_CONSTANT)
      crow.ii.wdel[device].freeze(1)
      clock.sleep(envelope_duration)
      crow.ii.wdel[device].freeze(0)
    end
  )
end

function WDelayPerformer:apply_effect(index, data)
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
end

return WDelayPerformer 