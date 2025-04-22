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
  local device = params:get('marco_performer_crow_device_'..sequence)
  local output = params:get('marco_performer_crow_outputs_'..sequence)
  local env_out = output == 1 and 1 or 3
  local cv_out = output == 1 and 2 or 4
  local atk, dec, sus, rel = params:get('marco_attack_'..sequence), params:get('marco_decay_'..sequence), params:get('marco_sustain_'..sequence), params:get('marco_release_'..sequence)
  local sus_period = envelope_duration - (envelope_duration * (atk + dec + rel) / 100)
  sus_period = sus_period >= 0 and sus_period or 0
  local envelope = '{ to(0,0), to('..envelope_duration * (atk / 100)..','..velocity..'), to('..envelope_duration * (dec / 100)..','..sus..'), to('..envelope_duration * (sus_period / 100)..','..sus..'), to('..envelope_duration * (rel / 100)..',0) }'
  note = (note - params:get('marco_root'))/12
  if device == 1 then
    crow.output[env_out].action = envelope
    crow.output[cv_out].volts = note
  else
    crow.ii.crow[device - 1].output[env_out].action = envelope
    crow.ii.crow[device - 1].output[cv_out].volts = note
  end
end

function CrowPerformer:apply_effect(index, data)
  -- no-op
end

return CrowPerformer 