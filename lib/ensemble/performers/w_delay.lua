local music_util = require('musicutil')
local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5 / 127
local NOTE_CONSTANT = 1/127

local WDelayPerformer = {
  clocks = nil,
  name = WD,
  effects = nil
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
  self:init_effects()
end

function WDelayPerformer:_create_effect(effect_num)
  return function(data)
    print('[WDelayPerformer] Effect '..effect_num..' not implemented')
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
  if self.clocks[sequence] then
    clock.cancel(self.clocks[sequence])
  end
  self.clocks[sequence] = clock.run(
    function()
      crow.ii.wdel[device].feedback(params:get('marco_performer_w_feedback_'..sequence))
      crow.ii.wdel[device].filter(params:get('marco_performer_w_filter_'..sequence))
      crow.ii.wdel[device].rate(params:get('marco_performer_w_rate_'..sequence))
      crow.ii.wdel[device].mod_rate(params:get('marco_performer_w_mod_rate_'..sequence))
      crow.ii.wdel[device].mod_amount(params:get('marco_performer_w_mod_amount_'..sequence))
      -- todo param for modifying the time formula (maybe for every sequences  like a regional cosmo constant)
      crow.ii.wdel[device].time(envelope_duration * (1 - (note * NOTE_CONSTANT)))
      crow.ii.wdel[device].freq(music_util.note_num_to_freq(note))
      crow.ii.wdel[device].pluck(velocity * VELOCITY_CONSTANT)
      crow.ii.wdel[device].freeze(1)
      clock.sleep(envelope_duration)
      crow.ii.wdel[device].freeze(0)
    end
  )
end

return WDelayPerformer
