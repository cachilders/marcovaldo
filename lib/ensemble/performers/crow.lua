local Performer = include('lib/ensemble/performer')
local GATE = 5

local CrowPerformer = {
  name = CROW
}

setmetatable(CrowPerformer, { __index = Performer })

function CrowPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowPerformer:_create_effect(effect_num)
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

function CrowPerformer:play_note(sequence, note, velocity, envelope_duration)
  local peak = velocity * GATE /127
  local device = params:get('marco_performer_crow_device_'..sequence)
  local output = params:get('marco_performer_crow_outputs_'..sequence)
  local gate = params:get('marco_performer_crow_gate_'..sequence)
  local slew = envelope_duration * params:get('marco_performer_slew_'..sequence) / 100
  local env_out = output == 1 and 1 or 3
  local cv_out = output == 1 and 2 or 4
  local atk, dec, sus, rel = params:get('marco_attack_'..sequence), params:get('marco_decay_'..sequence), params:get('marco_sustain_'..sequence), params:get('marco_release_'..sequence)
  local sus_dur = envelope_duration - (envelope_duration * (atk + dec + rel) / 100)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  sus = sus * peak
  sus_dur = sus_dur >= 0 and sus_dur or 0
  local a, d, sus_v, r = envelope_duration * atk / 100, envelope_duration * dec / 100, sus, envelope_duration * rel / 100
  local adj_note = note - params:get('marco_root')
  local vo = (adj_note >= 0 and adj_note or 0) / 12
  local voice_clock = self:_get_next_clock('voice')
  for i = 1, repeats do
    if voice_clock then
      clock.cancel(voice_clock)
    end
    voice_clock = clock.run(
      function()
        if device == 1 then
          crow.output[cv_out].slew = slew
          crow.output[cv_out].volts = vo
          if gate == 1 then
            crow.output[env_out].shape = 'now'
            crow.output[env_out].action = string.format("pulse(%f, %f)", envelope_duration, GATE)
          elseif gate == 2 then
            local envelope = string.format(
              "{ to(0,0), to(%f,%f), to(%f,%f), to(%f,%f), to(0,%f) }",
              peak,
              a,
              sus_v,
              d,
              sus_v,
              sus_dur,
              r
            )
            crow.output[env_out].shape = 'linear'
            crow.output[env_out].action = envelope
          end
          crow.output[env_out]()
        else
          device = device - 1
          crow.ii.crow[device].slew(cv_out, slew)
          crow.ii.crow[device].volts(cv_out, vo)
          if gate == 1 then
            crow.ii.crow[device].volts(env_out, GATE)
            clock.sleep(divided_duration)
            crow.ii.crow[device].volts(env_out, 0)
          elseif gate == 2 then
            crow.ii.crow[device].slew(env_out, 0)
            crow.ii.crow[device].volts(env_out, 0)
            crow.ii.crow[device].slew(env_out, a)
            crow.ii.crow[device].volts(env_out, peak)
            clock.sleep(a)
            crow.ii.crow[device].slew(env_out, d)
            crow.ii.crow[device].volts(env_out, sus_v)
            clock.sleep(d)
            clock.sleep(sus_dur)
            crow.ii.crow[device].slew(env_out, r)
            crow.ii.crow[device].volts(env_out, 0)
          end
        end
        if self.repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return CrowPerformer
