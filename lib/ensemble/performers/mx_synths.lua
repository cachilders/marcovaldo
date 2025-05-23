engine.name='MxSynths'

local Performer = include('lib/ensemble/performer')

local MxSynthsPerformer = {
  name = MX
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
  self:_init_clocks()
  self:_init_effects()
end

function MxSynthsPerformer:_create_effect(effect_num)
  return function(data)
    local mod_reset_value = params:get('mxsynths_mod'..effect_num)
    local beat_time = 60 / params:get('clock_tempo')
    local mod_new_value = (1/32) * ((data.x * data.y) - 32)
    local effect_clock = self:_get_next_clock('effect')
    if effect_clock then
      clock.cancel(effect_clock)
    end
    effect_clock = clock.run(
      function()
        engine.mx_set('mod'..effect_num, mod_new_value)
        clock.sleep(beat_time)
        engine.mx_set('mod'..effect_num, mod_reset_value)
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
