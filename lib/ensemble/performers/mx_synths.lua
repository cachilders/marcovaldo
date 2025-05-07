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

function MxSynthsPerformer:get_cat_breeds()
  local breeds = {}
  for i = 1, 4 do
    table.insert(breeds, { mod = i, id = 'mxsynths_mod'..i })
  end
  return breeds
end

function MxSynthsPerformer:init()
  print('[MxSynthsPerformer:init] Starting initialization')
  local mxsynths = include('mx.synths/lib/mx.synths')
  self.mx = mxsynths:new()
  params:set('mxsynths_synth', 7)
  -- Register MX.Synths mods as cat breeds by default
  if cat_breed_registry and cat_breed_registry.register_breeds then
    print('[MxSynthsPerformer:init] Registering breeds:')
    local breeds = self:get_cat_breeds()
    for i, breed in ipairs(breeds) do
      print('  Breed', i, ':')
      print('    mod:', breed.mod)
      print('    id:', breed.id)
    end
    cat_breed_registry:register_breeds(self, breeds)
  else
    print('[MxSynthsPerformer:init] No cat_breed_registry available')
  end
end

function MxSynthsPerformer:apply_effect(breed, data)
  print('[MxSynthsPerformer:apply_effect] Received:')
  print('  breed:', breed)
  print('  data:', data)
  -- TODO: Implement effect handling once we understand the data structure
  -- local mod_reset_value = params:get('mxsynths_mod'..breed.mod)
  -- local beat_time = 60 / params:get('clock_tempo')
  -- local mod_new_value = (1/32) * ((data[1] * data[2]) - 32)
  -- clock.run(
  --   function()
  --     engine.mx_set('mod'..breed.mod, mod_new_value)
  --     clock.sleep(beat_time)
  --     engine.mx_set('mod'..breed.mod, mod_reset_value)
  --   end
  -- )
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