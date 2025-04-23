local Performer = include('lib/ensemble/performer')

local CrowPerformer = {
  name = 'Crow'
}

setmetatable(CrowPerformer, { __index = Performer })

function CrowPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CrowPerformer:init()
  -- Initialize Crow
end

function CrowPerformer:play_note(sequence, note, velocity, envelope_duration)
  local peak = velocity * 10 /127
  local device = params:get('marco_performer_crow_device_'..sequence)
  local output = params:get('marco_performer_crow_outputs_'..sequence)
  local gate = params:get('marco_performer_crow_gate_'..sequence)
  local slew = envelope_duration * params:get('marco_performer_slew_'..sequence) / 100
  local env_out = output == 1 and 1 or 3
  local cv_out = output == 1 and 2 or 4
  local atk, dec, sus, rel = params:get('marco_attack_'..sequence), params:get('marco_decay_'..sequence), params:get('marco_sustain_'..sequence), params:get('marco_release_'..sequence)
  local sus_dur = envelope_duration - (envelope_duration * (atk + dec + rel) / 100)
  sus = sus * peak / 100
  sus_dur = sus_dur >= 0 and sus_dur or 0
  local a, d, sus_v, r = envelope_duration * atk / 100, envelope_duration * dec / 100, sus, envelope_duration * rel / 100
  note = note / 12
  if device == 1 then
    crow.output[cv_out].slew = slew
    crow.output[cv_out].volts = note
    if gate == 1 then
      crow.output[env_out].action = string.format("pulse(%f, %f)", envelope_duration, peak)
      crow.output[env_out]()
    elseif gate == 2 then
      local envelope = string.format("{ to(0,0), to(%f,%f), to(%f,%f), to(%f,%f), to(0,%f) }", peak, a, sus_v, d, sus_v, sus_dur, r)
      crow.output[env_out].action = envelope
      crow.output[env_out]()
    end
  else
    device = device - 1
    crow.ii.crow[device].slew(cv_out, slew)
    crow.ii.crow[device].volts(cv_out, note)
    if gate == 1 then
      clock.run(
        function()
          crow.ii.crow[device].volts(env_out, 10) -- does not reflect velocity. pure gate.
          clock.sleep(envelope_duration)
          crow.ii.crow[device].volts(env_out, 0)
        end
      )
    elseif gate == 2 then
      clock.run(
        function()
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
      )
    end
  end
end

function CrowPerformer:apply_effect(index, data)
  -- an option here would be to set some globals that affect the notes being played
  -- looping, tightening, octave transposition, etc.
end

return CrowPerformer 