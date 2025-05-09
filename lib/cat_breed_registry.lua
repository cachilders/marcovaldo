local observable = require('container.observable')

local CatBreedRegistry = {}
CatBreedRegistry.__index = CatBreedRegistry

function CatBreedRegistry:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  instance.breeds = observable.new({})
  return instance
end

function CatBreedRegistry:handle_sequence_performer_change(sequence)
  print('[CatBreedRegistry:handle_sequence_performer_change] Handling change for sequence:', sequence)
  
  local registry = self.breeds()
  
  -- Loop through all sequences to collect effects
  for seq = 1, 4 do
    local performer_name = params:get('marco_performer_'..seq)
    local performer = ensemble.performers[performer_name]
    
    if performer and performer.get_effects then
      local effects = performer:get_effects()
      for _, effect in ipairs(effects) do
        local effect_key = seq..'_'..effect.id
        if not registry[effect_key] then
          registry[effect_key] = {
            effect = effect.effect,
            id = effect.id,
            sequence = seq
          }
        end
      end
    end
  end
  
  -- Update the registry with the new effects
  self.breeds:set(registry)
end

function CatBreedRegistry:get()
  local function log_data(data)
    for k, v in pairs(data) do
      print('    '..k..':', v)
    end
  end

  local registry = self.breeds()
  print('[CatBreedRegistry:get] Retrieved breeds:')
  for breed_id, breed in pairs(registry) do
    print('  Breed', breed_id, ':')
    log_data(breed)
  end
  -- Convert to array for random selection
  local breeds = {}
  for _, breed in pairs(registry) do
    table.insert(breeds, breed)
  end
  return breeds
end

function CatBreedRegistry:subscribe(key, fn)
  self.breeds:register(key, fn)
end

return CatBreedRegistry
