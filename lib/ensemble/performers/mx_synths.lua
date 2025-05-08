engine.name='MxSynths'

local Performer = include('lib/ensemble/performer')

local MxSynthsPerformer = {
  mx = nil,
  name = 'Mx. Synths'
}

setmetatable(MxSynthsPerformer, { __index = Performer })

function MxSynthsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MxSynthsPerformer:get_effects()
  return {
    { effect = "mod1", id = "mxsynths_mod1" },
    { effect = "mod2", id = "mxsynths_mod2" },
    { effect = "mod3", id = "mxsynths_mod3" },
    { effect = "mod4", id = "mxsynths_mod4" }
  }
end

function MxSynthsPerformer:init()
  print('[MxSynthsPerformer:init] Starting initialization')
  local mxsynths = include('mx.synths/lib/mx.synths')
  self.mx = mxsynths:new()
  params:set('mxsynths_synth', 7)
end

function MxSynthsPerformer:apply_effect(effect, data)
  print('[MxSynthsPerformer:apply_effect] Received:')
  print('  effect:', effect)
  print('  data:', data)
  local mod_num = tonumber(string.match(effect.effect, "%d+"))
  if mod_num then
    local mod_reset_value = params:get('mxsynths_mod'..mod_num)
    local beat_time = 60 / params:get('clock_tempo')
    local mod_new_value = (1/32) * ((data.x * data.y) - 32)
    clock.run(
      function()
        engine.mx_set('mod'..mod_num, mod_new_value)
        clock.sleep(beat_time)
        engine.mx_set('mod'..mod_num, mod_reset_value)
      end
    )
  end
end

function MxSynthsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local synth = self.mx.synths[params:get('mxsynths_synth')]
  self.mx:play({
    synth = synth,
    note = note,
    velocity = velocity,
    attack = envelope_duration * (params:get('marco_attack_'..sequence) / 100),
    decay = envelope_duration * (params:get('marco_decay_'..sequence) / 100),
    sustain = params:get('marco_sustain_'..sequence) / 100,
    release = envelope_duration * (params:get('marco_release_'..sequence) / 100)
  })
end

return MxSynthsPerformer