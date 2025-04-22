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
  local peak_env_volts = velocity * 10 /127
  local device = params:get('marco_performer_crow_device_'..sequence)
  local output = params:get('marco_performer_crow_outputs_'..sequence)
  local env_out = output == 1 and 1 or 3
  local cv_out = output == 1 and 2 or 4
  local atk, dec, sus, rel = params:get('marco_attack_'..sequence), params:get('marco_decay_'..sequence), params:get('marco_sustain_'..sequence), params:get('marco_release_'..sequence)
  local sus_period = envelope_duration - (envelope_duration * (atk + dec + rel) / 100)
  sus = sus * peak_env_volts / 100
  sus_period = sus_period >= 0 and sus_period or 0
  envelope = string.format("{ to(0,0), to(%f,%f), to(%f,%f), to(%f,%f), to(0,%f) }",
    peak_env_volts,
    envelope_duration * (atk / 100),
    sus,
    envelope_duration * (dec / 100),
    sus,
    envelope_duration * (sus_period / 100),
    envelope_duration * (rel / 100))
  note = note / 12
  if device == 1 then
    print(note, envelope)
    crow.output[cv_out].volts = note
    crow.output[env_out].action = envelope
    crow.output[env_out]()
  else
    clock.run(
      function()
        -- set slew or whatever else we can...ar, for instance
        crow.ii.crow[device - 1].volts(env_out, 10)
        crow.ii.crow[device - 1].volts(cv_out, note)
        clock.sleep(envelope_duration)
        crow.ii.crow[device - 1].volts(env_out, 0)
      end
    )
  end
end

function CrowPerformer:apply_effect(index, data)
  -- no-op
end

return CrowPerformer 