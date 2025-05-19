local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127 -- to test

local WSynthPerformer = {
  name = WS
}

setmetatable(WSynthPerformer, { __index = Performer })

function WSynthPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSynthPerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    local effect_clock = self:_get_next_clock('effect')
    if effect_clock then
      clock.cancel(effect_clock)
    end
    effect_clock = clock.run(
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

function WSynthPerformer._scale_to_w(val)
  return (val*0.1) - 5
end

function WSynthPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  local attack = self._scale_to_w(params:get('marco_attack_'..sequence))
  local curve = params:get('marco_performer_w_curve_'..sequence)
  local ramp = params:get('marco_performer_w_ramp_'..sequence)
  local fm_i = params:get('marco_performer_w_fm_i_'..sequence)
  local fm_env = params:get('marco_performer_w_fm_env_'..sequence)
  local fm_rat_n = params:get('marco_performer_w_fm_rat_n_'..sequence)
  local fm_rat_d = params:get('marco_performer_w_fm_rat_d_'..sequence)
  local adj_note = note - params:get('marco_root')
  local vo = (adj_note >= 0 and adj_note or 0) / 12
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  local voice_index = self.next_clock_index['voice']
  local voice_clock = self:_get_next_clock('voice')
  for i = 1, repeats do
    if voice_clock then
      clock.cancel(voice_clock)
    end
    voice_clock = clock.run(
      function()
        crow.ii.wsyn[device].ar_mode(0)
        crow.ii.wsyn[device].lpg_time(divided_duration)
        crow.ii.wsyn[device].curve(curve)
        crow.ii.wsyn[device].ramp(ramp)
        crow.ii.wsyn[device].fm_index(fm_i)
        crow.ii.wsyn[device].fm_env(fm_env)
        crow.ii.wsyn[device].fm_ratio(fm_rat_n, fm_rat_d)
        crow.ii.wsyn[device].lpg_symmetry(attack)
        crow.ii.wsyn[device].play_voice(voice_index, vo, velocity * VELOCITY_CONSTANT)
        clock.sleep(divided_duration)
        crow.ii.wsyn[device].play_voice(voice_index, vo, 0)
      end
    )
  end
end

return WSynthPerformer
