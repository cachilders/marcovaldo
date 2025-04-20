engine.name='MxSynths'

local Performer = include('lib/performer')

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

function MxSynthsPerformer:init()
  local mxsynths = include('mx.synths/lib/mx.synths')
  self.mx = mxsynths:new()
  params:set('mxsynths_synth', 7)
end

function MxSynthsPerformer:apply_effect(index, data)
  local mod_reset_value = params:get('mxsynths_mod'..index)
  local beat_time = 60 / params:get('clock_tempo')
  local mod_new_value = (1/32) * ((data[1] * data[2]) - 32)
  clock.run(
    function()
      engine.mx_set('mod'..index, mod_new_value)
      clock.sleep(beat_time)
      engine.mx_set('mod'..index, mod_reset_value)
    end
  )
end

function MxSynthsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local synth = self.mx.synths[params:get('mxsynths_synth')]
  self.mx:play({
    synth = synth,
    note = note,
    velocity = velocity,
    attack = envelope_duration * (params:get('marco_attack_'..voice) / 100),
    decay = envelope_duration * (params:get('marco_decay_'..voice) / 100),
    sustain = params:get('marco_sustain_'..voice) / 100,
    release = envelope_duration * (params:get('marco_release_'..voice) / 100)
  })
end

return MxSynthsPerformer 